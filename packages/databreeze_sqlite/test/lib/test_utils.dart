import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:logging/logging.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:test/test.dart';

SqliteMigrations createMigrations(List<String> migrations) {
  return SqliteMigrations()..add(
    SqliteMigration(
      1,
      (tx) async {
        for (final sql in migrations) {
          await tx.execute(sql);
        }
      },
    ),
  );
}

Future<void> expectTableRows(
  SqliteWriteContext db,
  String sql,
  List<Object?> params,
  List<List<Object?>> rows, {
  Logger? log,
}) async {
  log?.finest('$sql ($params)');

  final res = await db.execute(sql, params);
  final actualRows = res.rows;

  expect(
    actualRows,
    equals(rows),
  );
}

Future<void> expectStoreTableRows(
  BreezeSqliteStore store,
  String sql,
  List<Object?> params,
  List<List<Object?>> rows, {
  Logger? log,
}) async {
  final db = await store.database;
  await expectTableRows(db, sql, params, rows, log: log);
}

// ---

typedef TableColumn = ({String name, String type, bool notNull, dynamic defaultValue, bool primaryKey});

Future<void> expectTable(
  SqliteWriteContext db,
  String name,
  List<TableColumn> columns, {
  Logger? log,
}) async {
  final sql = 'PRAGMA table_info($name)';
  log?.finest(sql);

  final res = await db.execute(sql);
  final tableColumns = res
      .map<TableColumn>(
        (col) => (
          name: col['name'],
          type: col['type'],
          notNull: (col['notnull'] == 1),
          defaultValue: col['dflt_value'],
          primaryKey: (col['pk'] == 1),
        ),
      )
      .toList();

  expect(
    tableColumns,
    equals(columns),
  );
}

Future<void> expectStoreTable(
  BreezeSqliteStore store,
  String name,
  List<TableColumn> columns, {
  Logger? log,
}) async {
  final db = await store.database;
  await expectTable(db, name, columns, log: log);
}
