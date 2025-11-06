import 'package:databreeze/databreeze.dart';
import 'package:sqlite_async/sqlite_async.dart';

typedef BreezeSqliteModelSchemaMigrateHandler = BreezeModelSchemaMigrateHandler<SqliteWriteContext>;

mixin BreezeSqliteMigratableModelSchema on BreezeBaseModelSchema {
  abstract final BreezeSqliteModelSchemaMigrateHandler? onBeforeMigrate;
  abstract final BreezeSqliteModelSchemaMigrateHandler? onAfterMigrate;
}

class BreezeSqliteModelSchema extends BreezeModelSchema with BreezeSqliteMigratableModelSchema {
  @override
  final BreezeSqliteModelSchemaMigrateHandler? onBeforeMigrate;

  @override
  final BreezeSqliteModelSchemaMigrateHandler? onAfterMigrate;

  BreezeSqliteModelSchema({
    required super.name,
    super.prevName,
    required super.columns,
    this.onBeforeMigrate,
    this.onAfterMigrate,
  });
}

class BreezeSqliteModelSchemaVersion extends BreezeModelSchemaVersion with BreezeSqliteMigratableModelSchema {
  @override
  final BreezeSqliteModelSchemaMigrateHandler? onBeforeMigrate;

  @override
  final BreezeSqliteModelSchemaMigrateHandler? onAfterMigrate;

  BreezeSqliteModelSchemaVersion({
    super.version,
    required super.name,
    super.prevName,
    required super.columns,
    this.onBeforeMigrate,
    this.onAfterMigrate,
  });
}
