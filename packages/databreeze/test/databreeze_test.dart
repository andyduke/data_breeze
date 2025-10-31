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
}
