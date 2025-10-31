import 'package:sqlite_async/sqlite_async.dart';

final _createTaskTable = '''CREATE TABLE tasks(
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
        await tx.execute(_createTaskTable);
      },
    ),
  );

final singleTaskMigration = SqliteMigrations()
  ..add(
    SqliteMigration(
      1,
      (tx) async {
        await tx.execute(_createTaskTable);

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
        await tx.execute(_createTaskTable);

        await tx.execute('''
  INSERT INTO tasks(id, name, note, created_at, file) VALUES(1, 'File 1', NULL, '2025-10-30 12:00:00+03:00', 'path/to/file1')
''');

        await tx.execute('''
  INSERT INTO tasks(id, name, note, created_at, file) VALUES(2, 'File 2', NULL, '2025-10-30 12:00:00+03:00', 'path/to/file2')
''');
      },
    ),
  );
