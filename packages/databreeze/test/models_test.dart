import 'package:databreeze/databreeze.dart';
import 'package:test/test.dart';

import 'lib/test_store.dart';

// #region The base model

abstract final class UploadTaskColumns {
  static const id = 'id';
  static const name = 'name';
  static const note = 'note';
  static const createdAt = 'created_at';
}

/// The base model, the foundation for the full model (R/W)
/// and the view model (R/O).
abstract class UploadTaskBase extends BreezeAbstractModel<int> {
  abstract final String name;
  abstract final String? note;
  abstract final DateTime createdAt;

  static final blueprint = BreezeModelBlueprint<UploadTaskBase>(
    name: 'upload_tasks',
    columns: [
      BreezeModelColumn<int>(UploadTaskColumns.id, isPrimaryKey: true),
      BreezeModelColumn<String>(UploadTaskColumns.name),
      BreezeModelColumn<String?>(UploadTaskColumns.note),
      BreezeModelColumn<DateTime>(UploadTaskColumns.createdAt),
    ],
    builder: UploadTask.fromRecord,
  );
}

// #endregion

// #region The full model, based on the base model

class UploadTask extends UploadTaskBase with BreezeModel<int> {
  @override
  String name;

  @override
  String? note;

  @override
  DateTime createdAt;

  static final blueprint = UploadTaskBase.blueprint.extend<UploadTask>(builder: UploadTask.fromRecord);

  @override
  BreezeModelBlueprint get schema => blueprint;

  UploadTask({
    required this.name,
    this.note,
    required this.createdAt,
  });

  factory UploadTask.fromRecord(Map<String, dynamic> record) => UploadTask(
    name: record[UploadTaskColumns.name] ?? 'n/a',
    note: record[UploadTaskColumns.note],
    createdAt: record[UploadTaskColumns.createdAt],
  );

  @override
  Map<String, dynamic> toRecord() => {
    UploadTaskColumns.name: name,
    UploadTaskColumns.note: note,
    UploadTaskColumns.createdAt: createdAt,
  };
}

// #endregion

// #region The view model, based on the base model

abstract final class UploadTaskWithProgressColumns {
  static const progress = 'progress';
}

class UploadTaskWithProgress extends UploadTaskBase with BreezeModelView<int> {
  @override
  final String name;

  @override
  final String? note;

  @override
  final DateTime createdAt;

  final double progress;

  static final blueprint = UploadTaskBase.blueprint.extend<UploadTaskWithProgress>(
    columns: [
      ...UploadTaskBase.blueprint.columns.values,
      BreezeModelColumn<double>(UploadTaskWithProgressColumns.progress),
    ],
    builder: UploadTaskWithProgress.fromRecord,
  );

  UploadTaskWithProgress({
    required this.name,
    this.note,
    required this.createdAt,
    this.progress = 0.0,
  });

  factory UploadTaskWithProgress.fromRecord(Map<String, dynamic> record) => UploadTaskWithProgress(
    name: record[UploadTaskColumns.name] ?? 'n/a',
    note: record[UploadTaskColumns.note],
    createdAt: record[UploadTaskColumns.createdAt],
    progress: record[UploadTaskWithProgressColumns.progress] ?? 0.0,
  );
}

// #endregion

// #region The full model (typical use case)

abstract final class UserColumns {
  static const id = 'id';
  static const name = 'name';
}

class User extends BreezeModel<int> {
  String name;

  static final blueprint = BreezeModelBlueprint<User>(
    name: 'users',
    columns: [BreezeModelColumn<int>(UserColumns.id, isPrimaryKey: true), BreezeModelColumn<String>(UserColumns.name)],
    builder: User.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  User({required this.name});

  factory User.fromRecord(Map<String, dynamic> record) => User(
    name: record[UserColumns.name] ?? 'n/a',
  );

  @override
  Map<String, dynamic> toRecord() => {
    UserColumns.name: name,
  };
}

// #endregion

/*
  final store = DataStore();

  // ---

  final users = await store.fetchAll<User>();
  final tasks = await store.fetchAll<UploadTask>();
  final tasksWithProgress = await store.fetchAll<UploadTaskWithProgress>();

  // ---

  final user = users.first;
  await store.save(user);

  final task = tasks.first;
  await store.save(task);

  final taskWithProgress = tasksWithProgress.first;
  // Lint: The argument type 'UploadTaskWithProgress'
  // can't be assigned to the parameter type
  // 'BreezeModel<dynamic>'.
  await store.save(taskWithProgress);
*/

Future<void> main() async {
  group('Model/ViewModel CRUD', () {
    test('Fetch Full Model (extends Base Model)', () async {
      final createdAt = DateTime.now();

      final store = TestStore(
        models: {
          UploadTask.blueprint,
          UploadTaskWithProgress.blueprint,
          User.blueprint,
        },
        records: {
          'upload_tasks': {
            1: {
              'id': 1,
              'name': 'File 1',
              'note': null,
              'created_at': createdAt,
            },
          },
        },
      );

      final task = await store.fetch<UploadTask>(filter: BreezeField('id').eq(1));

      expect(task, isNotNull);
      expect(task!.isNew, isFalse);
      expect(task.id, isNotNull);
      expect(task.id, equals(1));
      expect(task.name, equals('File 1'));
    });

    test('Fetch View Model (extends Base Model)', () async {
      final createdAt = DateTime.now();

      final store = TestStore(
        models: {
          UploadTask.blueprint,
          UploadTaskWithProgress.blueprint,
          User.blueprint,
        },
        records: {
          'upload_tasks': {
            1: {
              'id': 1,
              'name': 'File 1',
              'note': null,
              'created_at': createdAt,
            },
          },
        },
      );

      final task = await store.fetch<UploadTaskWithProgress>(filter: BreezeField('id').eq(1));

      expect(task, isNotNull);
      expect(task!.id, isNotNull);
      expect(task.id, equals(1));
      expect(task.name, equals('File 1'));
      expect(task.progress, equals(0.0));
    });

    test('Save Full Model (extends Base Model)', () async {
      final createdAt = DateTime.now();

      final store = TestStore(
        models: {
          UploadTask.blueprint,
          UploadTaskWithProgress.blueprint,
          User.blueprint,
        },
        records: {
          'upload_tasks': {
            1: {
              'id': 1,
              'name': 'File 1',
              'note': null,
              'created_at': createdAt,
            },
          },
        },
      );

      final task = await store.fetch<UploadTask>(filter: BreezeField('id').eq(1));

      expect(task, isNotNull);
      expect(task!.isNew, isFalse);
      expect(task.id, isNotNull);
      expect(task.id, equals(1));
      expect(task.name, equals('File 1'));

      task.name += '*';
      await store.save(task);

      expect(
        store.records,
        equals(
          {
            'upload_tasks': {
              1: {
                'id': 1,
                'name': 'File 1*',
                'note': null,
                'created_at': createdAt,
              },
            },
          },
        ),
      );
    });

    test('Delete Full Model (extends Base Model)', () async {
      final createdAt = DateTime.now();

      final store = TestStore(
        models: {
          UploadTask.blueprint,
          UploadTaskWithProgress.blueprint,
          User.blueprint,
        },
        records: {
          'upload_tasks': {
            1: {
              'id': 1,
              'name': 'File 1',
              'note': null,
              'created_at': createdAt,
            },
          },
        },
      );

      final task = await store.fetch<UploadTask>(filter: BreezeField('id').eq(1));

      expect(task, isNotNull);
      expect(task!.isNew, isFalse);
      expect(task.id, isNotNull);
      expect(task.id, equals(1));
      expect(task.name, equals('File 1'));

      await store.delete(task);

      expect(
        store.records,
        equals(
          {
            'upload_tasks': {},
          },
        ),
      );
    });
  });
}
