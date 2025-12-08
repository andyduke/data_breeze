import 'package:sqlite_async/sqlite_async.dart';

final createTaskTableSql = '''CREATE TABLE tasks(
                    id INTEGER PRIMARY KEY,
                    name TEXT,
                    note TEXT NULL,
                    created_at TEXT,
                    file TEXT,
                    status INT DEFAULT 0
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
  INSERT INTO tasks(id, name, note, created_at, file, status) VALUES(1, 'File 1', NULL, '2025-10-30 12:00:00+03:00', 'path/to/file1', 1)
''');

        await tx.execute('''
  INSERT INTO tasks(id, name, note, created_at, file, status) VALUES(2, 'File 2', NULL, '2025-10-30 11:00:00+03:00', 'path/to/file2', 0)
''');
      },
    ),
  );

// ---

final createTaskProgressTableSql = '''CREATE TEMP TABLE task_progress(
                    task_id INTEGER PRIMARY KEY,
                    progress REAL
                )''';

final emptyTaskProgressMigration = SqliteMigrations()
  ..add(
    SqliteMigration(
      1,
      (tx) async {
        await tx.execute(createTaskProgressTableSql);
      },
    ),
  );

final singleTaskProgressMigration = SqliteMigrations()
  ..add(
    SqliteMigration(
      1,
      (tx) async {
        await tx.execute(createTaskProgressTableSql);

        await tx.execute('''
  INSERT INTO task_progress(task_id, progress) VALUES(1, 0.3)
''');
      },
    ),
  );
