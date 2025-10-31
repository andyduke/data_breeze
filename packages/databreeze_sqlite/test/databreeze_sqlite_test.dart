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
}
