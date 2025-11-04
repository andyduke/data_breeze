import 'package:databreeze/databreeze.dart';
import '../model_types.dart';

// Queries

/*
class QueryTaskById extends BreezeQueryById<Task> {
  QueryTaskById(
    super.id, {
    super.autoUpdate,
  }) : super(blueprint: Task.blueprint);
}

class QueryAllTasks extends BreezeQueryAll<Task> {
  QueryAllTasks({
    super.filter,
    super.sortBy,
    super.autoUpdate,
  }) : super(blueprint: Task.blueprint);
}
*/

/*
class QueryTaskById extends BreezeQuery<Task?> {
  final int id;

  QueryTaskById(this.id);

  @override
  bool autoUpdateWhen(BreezeStoreChange change) => (change.entity == Task.blueprint.name && change.id == id);

  @override
  Future<Task?> fetch(BreezeStore store) async {
    return store.fetch(
      blueprint: Task.blueprint,
      options: BreezeFetchOptions(
        filter: BreezeField(Task.blueprint.key).eq(id),
      ),
    );
  }
}

class QueryTaskAll extends BreezeQuery<List<Task>> {
  @override
  bool autoUpdateWhen(BreezeStoreChange change) => (change.entity == Task.blueprint.name);

  @override
  Future<List<Task>> fetch(BreezeStore store) async {
    return store.fetchAll(
      // table: 'tasks',
      blueprint: Task.blueprint,
    );
  }
}
*/

// Model

final class TaskColumns {
  static const id = 'id';
  static const name = 'name';
  static const note = 'note';
  static const createdAt = 'created_at';
  static const file = 'file';
}

class Task extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint<Task>(
    builder: Task.fromRecord,
    name: 'tasks',
    // key: 'id',
    columns: [
      BreezeModelColumn<int>(TaskColumns.id, isPrimaryKey: true),
      BreezeModelColumn<String>(TaskColumns.name),
      BreezeModelColumn<String?>(TaskColumns.note),
      BreezeModelColumn<DateTime>(TaskColumns.createdAt),
      BreezeModelColumn<XFile>(TaskColumns.file),
    ],
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;
  String? note;
  DateTime createdAt;
  XFile file;

  Task({
    super.id,
    required this.name,
    this.note,
    DateTime? createdAt,
    required this.file,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Task.fromRecord(BreezeDataRecord record) => Task(
    name: record[TaskColumns.name] ?? 'n/a',
    note: record[TaskColumns.note],
    createdAt: record[TaskColumns.createdAt],
    file: record[TaskColumns.file],
  );

  @override
  Map<String, dynamic> toRecord() => {
    TaskColumns.name: name,
    TaskColumns.note: note,
    TaskColumns.createdAt: createdAt,
    TaskColumns.file: file,
  };

  @override
  Future<void> afterDelete() async {
    await file.delete();
  }

  @override
  String toString() =>
      '''Task(
  id: $id,
  name: $name,
  note: ${note ?? '<null>'},
  createdAt: $createdAt,
  file: $file
)''';
}
