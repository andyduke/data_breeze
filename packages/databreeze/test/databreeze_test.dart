import 'package:databreeze/databreeze.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:test/test.dart';
import 'package:logging/logging.dart';
// import 'package:databreeze/databreeze.dart';

import 'lib/model_types.dart';
import 'lib/models/task.dart';
import 'lib/test_store.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.loggerName}] ${record.time} ${record.level.name}: ${record.message}');
  });

  final log = Logger('Breeze');

  group('Store fetch', () {
    test('Fetch single record', () async {
      final id = 1;
      final createdAt = DateTime.now();

      final store = TestStore(
        log: log,
        records: {
          id: {
            'id': id,
            'name': 'File 1',
            'note': null,
            'created_at': createdAt,
            'file': XFile('path/to/file1'),
          },
        },
      );

      final task = await store.fetch(
        blueprint: Task.blueprint,
        filter: BreezeField('id').eq(1),
      );

      expect(task, isNotNull);
      expect(task!.isNew, isFalse);
      expect(task.id, isNotNull);
      expect(task.name, equals('File 1'));
    });

    test('Fetch multiple records', () async {
      final store = TestStore(
        log: log,
        records: {
          1: {
            'id': 1,
            'name': 'File 1',
            'note': null,
            'created_at': DateTime.now(),
            'file': XFile('path/to/file1'),
          },
          2: {
            'id': 2,
            'name': 'File 2',
            'note': null,
            'created_at': DateTime.now(),
            'file': XFile('path/to/file2'),
          },
        },
      );

      final tasks = await store.fetchAll(blueprint: Task.blueprint);

      expect(tasks, hasLength(2));

      expect(tasks[0].id, equals(1));
      expect(tasks[0].name, equals('File 1'));

      expect(tasks[1].id, equals(2));
      expect(tasks[1].name, equals('File 2'));
    });
  });

  group('CRUD', () {
    test('Create', () async {
      final store = TestStore(
        log: log,
      );

      final newTask = Task(
        name: 'File 1',
        file: XFile('path/to/file1'),
      );

      await store.save(newTask);

      expect(newTask.isNew, isFalse);
      expect(newTask.id, isNotNull);
      expect(
        store.records,
        equals({
          newTask.id: {
            'id': newTask.id,
            'name': 'File 1',
            'note': null,
            'created_at': newTask.createdAt,
            'file': 'path/to/file1',
          },
        }),
      );
    });

    test('Read', () async {
      final id = 1;
      final createdAt = DateTime.now();

      final store = TestStore(
        log: log,
        records: {
          id: {
            'id': id,
            'name': 'File 1',
            'note': null,
            'created_at': createdAt,
            'file': XFile('path/to/file1'),
          },
        },
      );

      final query = QueryTaskById(id);
      final task = await query.fetch(store);

      expect(task, isNotNull);
      expect(task!.isNew, isFalse);
      expect(task.id, isNotNull);
      expect(task.name, equals('File 1'));
    });

    test('Update', () async {
      final id = 1;
      final createdAt = DateTime.now();

      final store = TestStore(
        log: log,
        records: {
          id: {
            'id': id,
            'name': 'File 1',
            'note': null,
            'created_at': createdAt,
            'file': 'path/to/file1',
          },
        },
      );

      final query = QueryTaskById(id);
      final task = await query.fetch(store);

      expect(task, isNotNull);
      expect(task!.isNew, isFalse);
      expect(task.id, isNotNull);
      expect(task.name, equals('File 1'));

      task.name += '*';
      await store.save(task);

      expect(
        store.records,
        equals({
          task.id: {
            'id': task.id,
            'name': 'File 1*',
            'note': null,
            'created_at': task.createdAt,
            'file': 'path/to/file1',
          },
        }),
      );
    });

    test('Delete', () async {
      final id1 = 1;
      final createdAt1 = DateTime.now();
      final id2 = 2;
      final createdAt2 = DateTime.now();

      final store = TestStore(
        log: log,
        records: {
          id1: {
            'id': id1,
            'name': 'File 1',
            'note': null,
            'created_at': createdAt1,
            'file': 'path/to/file1',
          },
          id2: {
            'id': id2,
            'name': 'File 2',
            'note': null,
            'created_at': createdAt2,
            'file': 'path/to/file2',
          },
        },
      );

      final query = QueryTaskById(id2);
      final task2 = await query.fetch(store);

      expect(task2, isNotNull);

      await store.delete(task2!);

      expect(
        store.records,
        equals({
          id1: {
            'id': id1,
            'name': 'File 1',
            'note': null,
            'created_at': createdAt1,
            'file': 'path/to/file1',
          },
        }),
      );
    });
  });

  group('Sort Order', () {
    test('Single field ASC', () async {
      final store = TestStore(
        log: log,
        records: {
          2: {
            'id': 2,
            'name': 'File 2',
            'note': null,
            'created_at': DateTime.parse('2025-10-31 14:00:00.000+03:30'),
            'file': XFile('path/to/file2'),
          },
          1: {
            'id': 1,
            'name': 'File 1',
            'note': null,
            'created_at': DateTime.parse('2025-10-31 15:00:00.000+03:30'),
            'file': XFile('path/to/file1'),
          },
        },
      );

      final query = QueryAllTasks(sortBy: [BreezeSortBy(TaskColumns.name)]);
      final tasks = await query.fetch(store);

      expect(tasks, hasLength(2));

      expect(tasks[0].id, equals(1));
      expect(tasks[0].name, equals('File 1'));

      expect(tasks[1].id, equals(2));
      expect(tasks[1].name, equals('File 2'));
    });

    test('Single field DESC', () async {
      final store = TestStore(
        log: log,
        records: {
          2: {
            'id': 2,
            'name': 'File 2',
            'note': null,
            'created_at': DateTime.parse('2025-10-31 14:00:00.000+03:30'),
            'file': XFile('path/to/file2'),
          },
          1: {
            'id': 1,
            'name': 'File 1',
            'note': null,
            'created_at': DateTime.parse('2025-10-31 15:00:00.000+03:30'),
            'file': XFile('path/to/file1'),
          },
        },
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
        records: {
          3: {
            'id': 3,
            'name': 'File 3',
            'note': null,
            'created_at': DateTime.parse('2025-10-31 14:00:00.000+03:30'),
            'file': XFile('path/to/file3'),
          },
          1: {
            'id': 1,
            'name': 'File 1',
            'note': null,
            'created_at': DateTime.parse('2025-10-31 15:00:00.000+03:30'),
            'file': XFile('path/to/file1'),
          },
          2: {
            'id': 2,
            'name': 'File 2',
            'note': null,
            'created_at': DateTime.parse('2025-10-31 14:00:00.000+03:30'),
            'file': XFile('path/to/file2'),
          },
        },
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
