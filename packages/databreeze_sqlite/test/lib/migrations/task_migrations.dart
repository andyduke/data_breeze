import 'package:sqlite_async/sqlite_async.dart';

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

final createTaskTableSql = '''CREATE TABLE tasks(
                    id INTEGER PRIMARY KEY,
                    name TEXT,
                    note TEXT NULL,
                    created_at TEXT,
                    file TEXT
                )''';

final emptyTaskMigration = SqliteMigrations()
  ..add(
    SqliteMigration(
      1,
      (tx) async {
        await tx.execute(createTaskTableSql);
      },
    ),
  );

final singleTaskMigration = SqliteMigrations()
  ..add(
    SqliteMigration(
      1,
      (tx) async {
        await tx.execute(createTaskTableSql);

        await tx.execute('''
  INSERT INTO tasks(id, name, note, created_at, file) VALUES(1, 'File 1', NULL, '2025-10-30 12:00:00+03:00', 'path/to/file1')
''');
      },
    ),
  );

final tasksMigration = SqliteMigrations()
  ..add(
    SqliteMigration(
      1,
      (tx) async {
        await tx.execute(createTaskTableSql);

        await tx.execute('''
  INSERT INTO tasks(id, name, note, created_at, file) VALUES(1, 'File 1', NULL, '2025-10-30 12:00:00+03:00', 'path/to/file1')
''');

        await tx.execute('''
  INSERT INTO tasks(id, name, note, created_at, file) VALUES(2, 'File 2', NULL, '2025-10-30 11:00:00+03:00', 'path/to/file2')
''');
      },
    ),
  );
