import 'package:databreeze/src/model_column.dart';
import 'package:databreeze/src/model_schema.dart';
import 'package:logging/logging.dart';

typedef BreezeModelSchemaMigrateHandler<D> = Future<void> Function(D db);

abstract class BreezeMigration<D> {
  final int version;
  final BreezeModelSchemaMigrateHandler<D>? onBeforeMigrate;
  final BreezeModelSchemaMigrateHandler<D>? onAfterMigrate;

  const BreezeMigration({
    required this.version,
    this.onBeforeMigrate,
    this.onAfterMigrate,
  });

  Future<void> execute(D db, Logger? log);

  // @protected
  Future<void> apply(D db, Logger? log) async {
    await onBeforeMigrate?.call(db);
    await execute(db, log);
    await onAfterMigrate?.call(db);
  }
}

typedef BreezeMigrationCallback<D> = Future<void> Function(D db);

typedef BreezeMigrationBeforeVersionCallback<D> =
    bool Function(
      D db,
      int version,
      BreezeBaseModelSchema schema,
    );
typedef BreezeMigrationAfterVersionCallback<D> =
    bool Function(
      D db,
      int prevVersion,
      int version,
      BreezeBaseModelSchema schema,
    );

abstract class BreezeMigrationDelegate<D> {
  const BreezeMigrationDelegate();

  Future<void> prepare(D db, Logger? log);

  Future<int> getSchemaVersion(D db, String name, Logger? log);
  Future<void> setSchemaVersion(D db, String name, int? version, Logger? log);

  Future<T> transaction<T>(D db, Logger? log, Future<T> Function(D tx) callback);

  BreezeMigration createTableMigration(BreezeBaseModelSchema schema, {required int version});
  BreezeMigration renameTableMigration(BreezeBaseModelSchema schema, {required int version});
  BreezeMigration deleteTableMigration(BreezeBaseModelSchema schema, {required int version});
  BreezeMigration rebuildTableMigration(BreezeBaseModelSchema from, BreezeBaseModelSchema to, {required int version});
  BreezeMigration addColumnMigration(BreezeBaseModelSchema schema, BreezeModelColumn column, {required int version});
  BreezeMigration renameColumnMigration(BreezeBaseModelSchema schema, BreezeModelColumn column, {required int version});
}

abstract class BreezeMigrationManager<D> {
  final BreezeMigrationDelegate<D> delegate;
  final Logger? log;

  const BreezeMigrationManager({
    required this.delegate,
    this.log,
  });

  List<BreezeMigration> createMigrationPlan(BreezeBaseModelSchema schema);

  Future<void> migrateSchema({
    required D db,
    required BreezeBaseModelSchema schema,
    required List<BreezeMigration> migrations,
    BreezeMigrationBeforeVersionCallback<D>? onBeforeVersion,
    BreezeMigrationAfterVersionCallback<D>? onAfterVersion,
  }) async {
    final schemaName = schema.prevName ?? schema.name;
    final currentVersion = await delegate.getSchemaVersion(db, schemaName, log);

    if (onBeforeVersion?.call(db, currentVersion, schema) ?? true) {
      final newMigrations = migrations.where((m) => m.version > currentVersion);

      for (final migration in newMigrations) {
        await migration.apply(db, log);

        final isDeleted = schema.isDeleted;

        // Update the schema version number in the database.
        if (isDeleted) {
          await delegate.setSchemaVersion(db, schema.name, null, log);
        } else {
          if (schema.prevName != null) {
            await delegate.setSchemaVersion(db, schema.prevName!, null, log);
          }

          if (onAfterVersion?.call(db, currentVersion, migration.version, schema) ?? true) {
            if (!isDeleted) {
              await delegate.setSchemaVersion(db, schema.name, migration.version, log);
            }
          }
        }
      }
    }
  }

  Future<void> migrate(
    D db,
    List<BreezeBaseModelSchema> schemas, {
    BreezeMigrationCallback<D>? onBefore,
    BreezeMigrationCallback<D>? onAfter,
    BreezeMigrationBeforeVersionCallback<D>? onBeforeVersion,
    BreezeMigrationAfterVersionCallback<D>? onAfterVersion,
  }) async {
    if (schemas.isNotEmpty) {
      await delegate.transaction(db, log, (tx) async {
        await onBefore?.call(tx);

        await delegate.prepare(tx, log);

        for (final schema in schemas) {
          log?.info(
            '* Migrating schema: ${(schema.prevName != null) ? '${schema.prevName} → ' : ''}${schema.name}',
          );

          final plan = createMigrationPlan(schema);
          await migrateSchema(
            db: tx,
            schema: schema,
            migrations: plan,
            onBeforeVersion: onBeforeVersion,
            onAfterVersion: onAfterVersion,
          );
        }

        await onAfter?.call(tx);
      });
    }
  }
}
