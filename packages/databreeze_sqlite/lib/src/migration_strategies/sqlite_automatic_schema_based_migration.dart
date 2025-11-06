import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration_manager.dart';
import 'package:logging/logging.dart';
import 'package:sqlite_async/sqlite_async.dart';

class BreezeSqliteAutomaticSchemaBasedMigration extends BreezeSchemaMigrationStrategy<SqliteWriteContext> {
  final Logger? log;

  BreezeSqliteAutomaticSchemaBasedMigration({
    super.filter,
    super.onBeforeMigration,
    super.onAfterMigration,
    super.onBeforeVersion,
    super.onAfterVersion,
    this.log,
  });

  @override
  Future<void> migrateSchemas(
    Iterable<BreezeBaseModelSchema> schemas, [
    SqliteWriteContext? db,
  ]) async {
    if (db != null) {
      final manager = BreezeSqliteMigrationManager(
        log: log,
      );
      await manager.migrate(
        db,
        schemas.toList(growable: false),
        onBefore: onBeforeMigration,
        onAfter: onAfterMigration,
        onBeforeVersion: onBeforeVersion,
        onAfterVersion: onAfterVersion,
      );
    }
  }
}
