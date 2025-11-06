import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/migratable_model_schema.dart';
import 'package:databreeze_sqlite/src/migration_manager/migrations/create_table_migration.dart';
import 'package:databreeze_sqlite/src/migration_manager/migrations/rename_table_migration.dart';
import 'package:databreeze_sqlite/src/migration_manager/migrations/delete_table_migration.dart';
import 'package:databreeze_sqlite/src/migration_manager/migrations/rebuild_table_migration.dart';
import 'package:databreeze_sqlite/src/migration_manager/migrations/add_column_migration.dart';
import 'package:databreeze_sqlite/src/migration_manager/migrations/rename_column_migration.dart';
import 'package:logging/logging.dart';
import 'package:sqlite_async/sqlite_async.dart';

class BreezeSqliteMigrationDelegate extends BreezeMigrationDelegate<SqliteWriteContext> {
  static const String migrationsTableName = '__breeze_schema_versions';

  const BreezeSqliteMigrationDelegate();

  @override
  Future<void> prepare(SqliteWriteContext db, Logger? log) async {
    final sql =
        '''
CREATE TABLE IF NOT EXISTS $migrationsTableName (
  table_name TEXT PRIMARY KEY,
  version INTEGER
)
''';

    log?.finer(sql);

    await db.execute(sql);
  }

  @override
  Future<int> getSchemaVersion(SqliteWriteContext db, String name, Logger? log) async {
    final sql = 'SELECT version FROM $migrationsTableName WHERE table_name = ?';

    log?.finer('$sql ($name)');

    final result = await db.execute(sql, [name]);
    return result.isNotEmpty ? (result.first['version'] ?? 0) : 0;
  }

  @override
  Future<void> setSchemaVersion(SqliteWriteContext db, String name, int? version, Logger? log) async {
    if (version != null) {
      final sql = 'REPLACE INTO $migrationsTableName (table_name, version) VALUES (?, ?)';
      log?.finer('$sql ($name, $version)');
      await db.execute(sql, [name, version]);
    } else {
      final sql = 'DELETE FROM $migrationsTableName WHERE table_name = ?';
      log?.finer('$sql ($name)');
      await db.execute(sql, [name]);
    }
  }

  @override
  Future<T> runInTransaction<T>(SqliteWriteContext db, covariant Future<T> Function(SqliteWriteContext tx) callback) {
    return db.writeTransaction(callback);
  }

  @override
  BreezeMigration<SqliteWriteContext> createTableMigration(
    covariant BreezeSqliteMigratableModelSchema schema, {
    required int version,
  }) => BreezeSqliteCreateTableMigration(schema, version: version);

  @override
  BreezeMigration<SqliteWriteContext> renameTableMigration(
    covariant BreezeSqliteMigratableModelSchema schema, {
    required int version,
  }) => BreezeSqliteRenameTableMigration(schema, version: version);

  @override
  BreezeMigration<SqliteWriteContext> deleteTableMigration(
    covariant BreezeSqliteMigratableModelSchema schema, {
    required int version,
  }) => BreezeSqliteDeleteTableMigration(schema, version: version);

  @override
  BreezeMigration<SqliteWriteContext> rebuildTableMigration(
    covariant BreezeSqliteMigratableModelSchema from,
    covariant BreezeSqliteMigratableModelSchema to, {
    required int version,
  }) => BreezeSqliteRebuildTableMigration(from, to, version: version);

  @override
  BreezeMigration<SqliteWriteContext> addColumnMigration(
    covariant BreezeSqliteMigratableModelSchema schema,
    BreezeModelColumn column, {
    required int version,
  }) => BreezeSqliteAddColumnMigration(schema, column, version: version);

  @override
  BreezeMigration<SqliteWriteContext> renameColumnMigration(
    covariant BreezeSqliteMigratableModelSchema schema,
    BreezeModelColumn column, {
    required int version,
  }) => BreezeSqliteRenameColumnMigration(schema, column, version: version);
}
