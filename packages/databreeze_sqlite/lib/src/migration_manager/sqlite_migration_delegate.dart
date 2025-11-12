import 'package:databreeze/databreeze.dart';
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
  Future<T> transaction<T>(
    SqliteWriteContext db,
    Logger? log,
    Future<T> Function(SqliteWriteContext tx) callback,
  ) async {
    log?.finer('BEGIN TRANSACTION');
    try {
      final result = await db.writeTransaction(callback);
      log?.finer('COMMIT');
      return result;
    } catch (e) {
      log?.finer('ROLLBACK');
      rethrow;
    }
  }

  @override
  BreezeMigration<SqliteWriteContext> createTableMigration(
    BreezeBaseModelSchema schema, {
    required int version,
    required Set<BreezeBaseTypeConverter> typeConverters,
  }) => BreezeSqliteCreateTableMigration(schema, version: version, typeConverters: typeConverters);

  @override
  BreezeMigration<SqliteWriteContext> renameTableMigration(
    BreezeBaseModelSchema schema, {
    required int version,
    required Set<BreezeBaseTypeConverter> typeConverters,
  }) => BreezeSqliteRenameTableMigration(schema, version: version, typeConverters: typeConverters);

  @override
  BreezeMigration<SqliteWriteContext> deleteTableMigration(
    BreezeBaseModelSchema schema, {
    required int version,
    required Set<BreezeBaseTypeConverter> typeConverters,
  }) => BreezeSqliteDeleteTableMigration(schema, version: version, typeConverters: typeConverters);

  @override
  BreezeMigration<SqliteWriteContext> rebuildTableMigration(
    BreezeBaseModelSchema from,
    BreezeBaseModelSchema to, {
    required int version,
    required Set<BreezeBaseTypeConverter> typeConverters,
  }) => BreezeSqliteRebuildTableMigration(from, to, version: version, typeConverters: typeConverters);

  @override
  BreezeMigration<SqliteWriteContext> addColumnMigration(
    BreezeBaseModelSchema schema,
    BreezeModelColumn column, {
    required int version,
    required Set<BreezeBaseTypeConverter> typeConverters,
  }) => BreezeSqliteAddColumnMigration(schema, column, version: version, typeConverters: typeConverters);

  @override
  BreezeMigration<SqliteWriteContext> renameColumnMigration(
    BreezeBaseModelSchema schema,
    BreezeModelColumn column, {
    required int version,
    required Set<BreezeBaseTypeConverter> typeConverters,
  }) => BreezeSqliteRenameColumnMigration(schema, column, version: version, typeConverters: typeConverters);
}
