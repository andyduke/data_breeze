import 'package:databreeze/databreeze.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';

abstract class BreezeSqliteMigration extends BreezeMigration<SqliteWriteContext> {
  const BreezeSqliteMigration({
    required super.version,
    super.onBeforeMigrate,
    super.onAfterMigrate,
  });

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
    int: 'INT',
    double: 'REAL',
    bool: 'INT',
  };

  @internal
  static String createColumnSql(BreezeModelColumn column) {
    final sqlType = _sqlTypes[column.type] ?? 'TEXT';
    final nullable = column.isNullable ? '' : 'NOT NULL';
    final pk = column.isPrimaryKey ? 'PRIMARY KEY' : '';

    final sql = '${column.name} $sqlType $nullable $pk'.trim();
    return sql;
  }
}
