import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/migratable_model_schema.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';

abstract class BreezeSqliteMigration extends BreezeMigration<SqliteWriteContext> {
  const BreezeSqliteMigration({
    required super.version,
    required super.typeConverters,
    super.onBeforeMigrate,
    super.onAfterMigrate,
  });

  static BreezeSqliteMigratableModelSchema? sqliteSchemaOf(BreezeBaseModelSchema schema) =>
      (schema is BreezeSqliteMigratableModelSchema) ? schema : null;

  List<String> generate();

  @override
  Future<void> execute(SqliteWriteContext db, Logger? log) async {
    final sqlScript = generate();

    for (final sql in sqlScript) {
      log?.finer(sql);

      await db.execute(sql);
    }
  }

  // ---

  static const _sqlTypes = {
    String: 'TEXT',
    int: 'INTEGER',
    double: 'REAL',
    bool: 'INT',
  };

  @internal
  static String createColumnSql(
    BreezeModelColumn column, [
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  ]) {
    final columnType = column.type;
    Type storageType = columnType;

    for (final typeConverter in typeConverters) {
      if (typeConverter.isDartType(columnType)) {
        storageType = typeConverter.storageType;
      }
    }

    // print('### ${column.name}<${column.type}>: $storageType');

    final sqlType = _sqlTypes[storageType] ?? 'TEXT';
    final nullable = (column.isPrimaryKey || column.isNullable) ? '' : ' NOT NULL';
    final pk = column.isPrimaryKey ? ' PRIMARY KEY' : '';

    final sql = '${column.name} $sqlType$nullable$pk'.trim();
    return sql;
  }
}
