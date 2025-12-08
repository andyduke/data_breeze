import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:sqlite_async/sqlite3_common.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:test/test.dart';
import 'package:logging/logging.dart';

import 'lib/migrations/product_migration.dart';
import 'lib/migrations/task_migrations.dart';
import 'lib/model_types.dart';
import 'lib/models/product.dart';
import 'lib/models/task.dart';
import 'lib/models/task_progress.dart';
import 'lib/models/task_with_progress.dart';
import 'lib/test_store.dart';
import 'lib/test_utils.dart';

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
        migrationStrategy: BreezeSqliteMigrations(emptyTaskMigration),
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
            [newTask.id, 'File 1', null, newTask.createdAt.toSqliteDateTime(), 'path/to/file1', 0],
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
        migrationStrategy: BreezeSqliteMigrations(singleTaskMigration),
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
        migrationStrategy: BreezeSqliteMigrations(singleTaskMigration),
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
            [task.id, 'File 1*', null, task.createdAt.toSqliteDateTime(), 'path/to/file1', 0],
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
        migrationStrategy: BreezeSqliteMigrations(tasksMigration),
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
            [1, 'File 1', null, '2025-10-30 12:00:00+03:00', 'path/to/file1', 1],
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
        migrationStrategy: BreezeSqliteMigrations(tasksMigration),
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
        migrationStrategy: BreezeSqliteMigrations(tasksMigration),
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
        migrationStrategy: BreezeSqliteMigrations(
          createMigrations([
            createTaskTableSql,
            "INSERT INTO tasks(id, name, note, created_at, file) VALUES(3, 'File 3', NULL, '2025-10-30 14:00:00+03:00', 'path/to/file3')",
            "INSERT INTO tasks(id, name, note, created_at, file) VALUES(1, 'File 1', NULL, '2025-10-30 15:00:00+03:00', 'path/to/file1')",
            "INSERT INTO tasks(id, name, note, created_at, file) VALUES(2, 'File 2', NULL, '2025-10-30 14:00:00+03:00', 'path/to/file2')",
          ]),
        ),
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
        migrationStrategy: BreezeSqliteMigrations(
          SqliteMigrations()..add(
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

  group('Query expression', () {
    test('SELECT with NOT', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(
          SqliteMigrations()..add(
            SqliteMigration(
              1,
              (tx) async {
                await tx.execute(createTaskTableSql);

                await tx.execute('''
  INSERT INTO tasks(id, name, note, created_at, file) VALUES(1, 'File 1', 'Test file', '2025-10-30 12:00:00+03:00', 'path/to')
''');

                await tx.execute('''
  INSERT INTO tasks(id, name, note, created_at, file) VALUES(2, 'File 2', 'Test file', '2025-10-30 11:00:00+03:00', 'path/to')
''');

                await tx.execute('''
  INSERT INTO tasks(id, name, note, created_at, file) VALUES(3, 'File 3', 'Test file', '2025-10-30 11:00:00+03:00', 'filename')
''');
              },
            ),
          ),
        ),
      );

      final query = BreezeQueryAll<Task>(
        filter:
            ~(BreezeField(TaskColumns.file).eq('path/to') //
                &
                BreezeField(TaskColumns.note).eq('Test file')),
      );
      final tasks = await query.fetch(store);

      expect(tasks, hasLength(1));

      expect(tasks[0].id, equals(3));
      expect(tasks[0].name, equals('File 3'));
    });
  });

  group('Upsert', () {
    test('Save new record', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(emptyTaskMigration),
      );

      final newTask = Task(
        name: 'File 1',
        file: XFile('path/to/file1'),
      )..id = 1;

      await store.save(newTask);

      expect(newTask.isNew, isFalse);
      expect(newTask.id, isNotNull);

      // ---

      final db = await store.database;

      final res = await db.execute('SELECT * FROM tasks');
      final rows = res.rows;

      log.finest('Actual rows: $rows');

      expect(
        rows,
        equals(
          [
            [newTask.id, 'File 1', null, newTask.createdAt.toSqliteDateTime(), 'path/to/file1', 0],
          ],
        ),
      );
    });

    test('Save existing record', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(singleTaskMigration),
      );

      final newTask = Task(
        name: 'File 1*',
        file: XFile('path/to/file1'),
      )..id = 1;

      await store.save(newTask);

      // ---

      final db = await store.database;

      final res = await db.execute('SELECT * FROM tasks');
      final rows = res.rows;

      log.finest('Actual rows: $rows');

      expect(
        rows,
        equals(
          [
            [newTask.id, 'File 1*', null, newTask.createdAt.toSqliteDateTime(), 'path/to/file1', 0],
          ],
        ),
      );
    });

    test('Save new record (custom pk)', () async {
      final store = TestStore(
        log: log,
        models: {
          TaskProgress.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(emptyTaskProgressMigration),
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
      );

      final newTaskProgress = TaskProgress(
        id: 1,
        progress: 0.2,
      );

      await store.save(newTaskProgress);

      expect(newTaskProgress.isNew, isFalse);
      expect(newTaskProgress.id, isNotNull);

      // ---

      final db = await store.database;

      final res = await db.execute('SELECT * FROM task_progress');
      final rows = res.rows;

      log.finest('Actual rows: $rows');

      expect(
        rows,
        equals(
          [
            [1, 0.2],
          ],
        ),
      );
    });

    test('Save existing record (custom pk)', () async {
      final store = TestStore(
        log: log,
        models: {
          TaskProgress.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(singleTaskProgressMigration),
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
      );

      final newTaskProgress = TaskProgress(
        id: 1,
        progress: 0.7,
      );

      await store.save(newTaskProgress);

      // ---

      final db = await store.database;

      final res = await db.execute('SELECT * FROM task_progress');
      final rows = res.rows;

      log.finest('Actual rows: $rows');

      expect(
        rows,
        equals(
          [
            [1, 0.7],
          ],
        ),
      );
    });
  });

  group('Filter type converters', () {
    test('Using store type converters (DateTime)', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(tasksMigration),
      );

      final query = BreezeQueryAll<Task>(
        filter: BreezeField('created_at') > DateTime.parse('2025-10-30 11:00:00+03:00'),
      );
      final tasks = await query.fetch(store);

      expect(tasks, hasLength(1));

      expect(tasks.first.id, equals(1));
      expect(tasks.first.name, equals('File 1'));
    });

    test('Using model blueprint type converters (TaskStatus)', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(tasksMigration),
      );

      final query = BreezeQueryAll<Task>(
        filter: BreezeField('status').eq(TaskStatus.running),
      );
      final tasks = await query.fetch(store);

      expect(tasks, hasLength(1));

      expect(tasks.first.id, equals(1));
      expect(tasks.first.name, equals('File 1'));
    });
  });

  group('Error handling', () {
    test('W/o onError handler', () async {
      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(singleTaskMigration),
      );

      final query = BreezeQueryWhere<Task>(
        BreezeField('not_exist').eq(1),
      );

      Task? task;
      try {
        task = await query.fetch(store);
      } catch (error) {
        expect(error, isA<SqliteException>());
        expect(
          error.toString(),
          r'''SqliteException(1): while preparing statement, no such column: not_exist, SQL logic error (code 1)
  Causing statement (at position 26): SELECT * FROM tasks WHERE not_exist = ? LIMIT 1''',
        );
      }

      expect(task, isNull);
    });

    test('With onError handler', () async {
      Object? actualError;

      final store = TestStore(
        log: log,
        models: {
          Task.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(singleTaskMigration),
        onError: (error, stackTrace) {
          actualError = error;

          // print('Error: $error');
          // print('$stackTrace');
        },
      );

      final query = BreezeQueryWhere<Task>(
        BreezeField('not_exist').eq(1),
      );

      Task? task;
      try {
        task = await query.fetch(store);
      } catch (error) {
        expect(error, isA<SqliteException>());
        expect(
          error.toString(),
          r'''SqliteException(1): while preparing statement, no such column: not_exist, SQL logic error (code 1)
  Causing statement (at position 26): SELECT * FROM tasks WHERE not_exist = ? LIMIT 1''',
        );

        expect(actualError, isA<SqliteException>());
        expect(
          actualError.toString(),
          error.toString(),
        );
      }

      expect(task, isNull);
      expect(actualError, isA<SqliteException>());
    });
  });

  group('Aggregation', () {
    test('COUNT', () async {
      final store = TestStore(
        log: log,
        models: {
          Product.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(
          createProductsMigration([
            {'id': 1, 'name': 'Product 1', 'price': null},
            {'id': 2, 'name': 'Product 2', 'price': 15},
          ]),
        ),
      );

      final prices = await store.count('products', 'price');

      expect(prices, equals(1));
    });

    test('SUM', () async {
      final store = TestStore(
        log: log,
        models: {
          Product.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(
          createProductsMigration([
            {'id': 1, 'name': 'Product 1', 'price': 10},
            {'id': 2, 'name': 'Product 2', 'price': 15},
          ]),
        ),
      );

      final prices = await store.sum<int>('products', 'price');

      expect(prices, equals(25));
    });

    test('AVG', () async {
      final store = TestStore(
        log: log,
        models: {
          Product.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(
          createProductsMigration([
            {'id': 1, 'name': 'Product 1', 'price': 10},
            {'id': 2, 'name': 'Product 2', 'price': 15},
          ]),
        ),
      );

      final prices = await store.average<double>('products', 'price');

      expect(prices, equals(12.5));
    });

    test('MIN', () async {
      final store = TestStore(
        log: log,
        models: {
          Product.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(
          createProductsMigration([
            {'id': 1, 'name': 'Product 1', 'price': 10},
            {'id': 2, 'name': 'Product 2', 'price': 15},
          ]),
        ),
      );

      final prices = await store.min<double>('products', 'price');

      expect(prices, equals(10));
    });

    test('MAX', () async {
      final store = TestStore(
        log: log,
        models: {
          Product.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(
          createProductsMigration([
            {'id': 1, 'name': 'Product 1', 'price': 10},
            {'id': 2, 'name': 'Product 2', 'price': 15},
          ]),
        ),
      );

      final prices = await store.max<double>('products', 'price');

      expect(prices, equals(15));
    });

    test('SUM with Filter', () async {
      final store = TestStore(
        log: log,
        models: {
          Product.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(
          createProductsMigration([
            {'id': 1, 'name': 'Product 1', 'price': 10},
            {'id': 2, 'name': 'Product 2', 'price': 15},
            {'id': 3, 'name': 'Product 3', 'price': 7},
            {'id': 4, 'name': 'Product 4', 'price': null},
          ]),
        ),
      );

      final prices = await store.sum<double>(
        'products',
        'price',
        filter: BreezeField('price') >= 10,
      );

      expect(prices, equals(25));
    });
  });
}
