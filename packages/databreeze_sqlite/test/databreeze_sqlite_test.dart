import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/sqlite_type_converters.dart';
import 'package:test/test.dart';
import 'package:logging/logging.dart';
// import 'package:databreeze/databreeze.dart';

import 'lib/migrations/task_migrations.dart';
import 'lib/model_types.dart';
import 'lib/models/task.dart';
import 'lib/test_store.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.loggerName}] ${record.time} ${record.level.name}: ${record.message}');
  });

  final log = Logger('Breeze');

  group('CRUD', () {
    test('Create', () async {
      final store = TestStore(
        log: log,
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
        migrations: singleTaskMigration,
      );

      final query = QueryTaskById(1);
      final task = await query.fetch(store);

      expect(task, isNotNull);
      expect(task!.isNew, isFalse);
      expect(task.id, isNotNull);
      expect(task.name, equals('File 1'));
    });

    test('Update', () async {
      final store = TestStore(
        log: log,
        migrations: singleTaskMigration,
      );

      final query = QueryTaskById(1);
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
        migrations: tasksMigration,
      );

      final query = QueryTaskById(2);
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
        migrations: tasksMigration,
      );

      final query = QueryAllTasks(sortBy: [BreezeSortBy(TaskColumns.createdAt)]);
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
        migrations: tasksMigration,
      );

      final query = QueryAllTasks(sortBy: [BreezeSortBy(TaskColumns.name, BreezeSortDir.desc)]);
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
        migrations: createMigrations([
          createTaskTableSql,
          "INSERT INTO tasks(id, name, note, created_at, file) VALUES(3, 'File 3', NULL, '2025-10-30 14:00:00+03:00', 'path/to/file3')",
          "INSERT INTO tasks(id, name, note, created_at, file) VALUES(1, 'File 1', NULL, '2025-10-30 15:00:00+03:00', 'path/to/file1')",
          "INSERT INTO tasks(id, name, note, created_at, file) VALUES(2, 'File 2', NULL, '2025-10-30 14:00:00+03:00', 'path/to/file2')",
        ]),
      );

      final query = QueryAllTasks(
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
}
