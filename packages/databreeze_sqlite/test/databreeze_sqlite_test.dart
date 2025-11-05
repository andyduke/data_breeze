import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/sqlite_type_converters.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:test/test.dart';
import 'package:logging/logging.dart';

import 'lib/migrations/task_migrations.dart';
import 'lib/model_types.dart';
import 'lib/models/task.dart';
import 'lib/models/task_with_progress.dart';
import 'lib/test_store.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.loggerName}] ${record.time} ${record.level.name}: ${record.message}');
  });

  final log = Logger('Breeze Sqlite');

  group('CRUD', () {
    test('Create', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrations: emptyTaskMigration,
      );

      final newTask = Task(
        name: 'File 1',
        file: XFile('path/to/file1'),
      );

      await store.save(newTask);

      expect(newTask.isNew, isFalse);
      expect(newTask.id, isNotNull);

      // ---

      final db = await store.database;

      final res = await db.execute('SELECT * FROM tasks');
      final rows = res.rows;

      log.finest('$rows');

      expect(
        rows,
        equals(
          [
            [newTask.id, 'File 1', null, newTask.createdAt.toSqliteDateTime(), 'path/to/file1'],
          ],
        ),
      );
    });

    test('Read', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrations: singleTaskMigration,
      );

      // final query = QueryTaskById(1);
      final query = BreezeQueryById<Task>(1);
      final task = await query.fetch(store);

      expect(task, isNotNull);
      expect(task!.isNew, isFalse);
      expect(task.id, isNotNull);
      expect(task.name, equals('File 1'));
    });

    test('Update', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrations: singleTaskMigration,
      );

      // final query = QueryTaskById(1);
      final query = BreezeQueryById<Task>(1);
      final task = await query.fetch(store);

      expect(task, isNotNull);
      expect(task!.isNew, isFalse);
      expect(task.id, isNotNull);
      expect(task.name, equals('File 1'));

      task.name += '*';
      await store.save(task);

      // ---

      final db = await store.database;

      final res = await db.execute('SELECT * FROM tasks');
      final rows = res.rows;

      log.finest('$rows');

      expect(
        rows,
        equals(
          [
            [task.id, 'File 1*', null, task.createdAt.toSqliteDateTime(), 'path/to/file1'],
          ],
        ),
      );
    });

    test('Delete', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrations: tasksMigration,
      );

      // final query = QueryTaskById(2);
      final query = BreezeQueryById<Task>(2);
      final task2 = await query.fetch(store);

      expect(task2, isNotNull);

      await store.delete(task2!);

      // ---

      final db = await store.database;

      final res = await db.execute('SELECT * FROM tasks');
      final rows = res.rows;

      log.finest('$rows');

      expect(
        rows,
        equals(
          [
            [1, 'File 1', null, '2025-10-30 12:00:00+03:00', 'path/to/file1'],
          ],
        ),
      );
    });
  });

  group('Sort Order', () {
    test('Single field ASC', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrations: tasksMigration,
      );

      // final query = QueryAllTasks(sortBy: [BreezeSortBy(TaskColumns.createdAt)]);
      final query = BreezeQueryAll<Task>(sortBy: [BreezeSortBy(TaskColumns.createdAt)]);
      final tasks = await query.fetch(store);

      expect(tasks, hasLength(2));

      expect(tasks[0].id, equals(2));
      expect(tasks[0].name, equals('File 2'));

      expect(tasks[1].id, equals(1));
      expect(tasks[1].name, equals('File 1'));
    });

    test('Single field DESC', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrations: tasksMigration,
      );

      // final query = QueryAllTasks(sortBy: [BreezeSortBy(TaskColumns.name, BreezeSortDir.desc)]);
      final query = BreezeQueryAll<Task>(sortBy: [BreezeSortBy(TaskColumns.name, BreezeSortDir.desc)]);
      final tasks = await query.fetch(store);

      expect(tasks, hasLength(2));

      expect(tasks[0].id, equals(2));
      expect(tasks[0].name, equals('File 2'));

      expect(tasks[1].id, equals(1));
      expect(tasks[1].name, equals('File 1'));
    });

    test('Multiple fields', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrations: createMigrations([
          createTaskTableSql,
          "INSERT INTO tasks(id, name, note, created_at, file) VALUES(3, 'File 3', NULL, '2025-10-30 14:00:00+03:00', 'path/to/file3')",
          "INSERT INTO tasks(id, name, note, created_at, file) VALUES(1, 'File 1', NULL, '2025-10-30 15:00:00+03:00', 'path/to/file1')",
          "INSERT INTO tasks(id, name, note, created_at, file) VALUES(2, 'File 2', NULL, '2025-10-30 14:00:00+03:00', 'path/to/file2')",
        ]),
      );

      // final query = QueryAllTasks(
      //   sortBy: [
      //     BreezeSortBy(TaskColumns.createdAt),
      //     BreezeSortBy(TaskColumns.name),
      //   ],
      // );
      final query = BreezeQueryAll<Task>(
        sortBy: [
          BreezeSortBy(TaskColumns.createdAt),
          BreezeSortBy(TaskColumns.name),
        ],
      );
      final tasks = await query.fetch(store);

      expect(tasks, hasLength(3));

      expect(tasks[0].id, equals(2));
      expect(tasks[0].name, equals('File 2'));

      expect(tasks[1].id, equals(3));
      expect(tasks[1].name, equals('File 3'));

      expect(tasks[2].id, equals(1));
      expect(tasks[2].name, equals('File 1'));
    });
  });

  group('Query with raw SQL', () {
    test('SELECT with JOIN', () async {
      final store = TestStore(
        log: log,
        models: {
          TaskWithProgress.blueprint,
        },
        migrations: SqliteMigrations()
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

                await tx.execute('''
CREATE TEMP TABLE task_progress(
  id INT PRIMARY KEY,
  task_id INT,
  progress REAL
)
''');

                await tx.execute('''
  INSERT INTO task_progress(id, task_id, progress) VALUES(1, 1, 0.3)
''');
              },
            ),
          ),
      );

      final query = QueryAllTaskWithProgress();
      final tasks = await query.fetch(store);

      expect(tasks, hasLength(2));

      expect(tasks[0].id, equals(1));
      expect(tasks[0].name, equals('File 1'));
      expect(tasks[0].progress, equals(0.3));

      expect(tasks[1].id, equals(2));
      expect(tasks[1].name, equals('File 2'));
      expect(tasks[1].progress, isNull);
    });
  });
}
