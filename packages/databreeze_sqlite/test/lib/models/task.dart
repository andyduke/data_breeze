import 'package:databreeze/databreeze.dart';
import '../model_types.dart';

// Queries

class QueryTaskById extends BreezeQueryById<Task> {
  QueryTaskById(
    super.id, {
    super.autoUpdate,
  }) : super(blueprint: Task.blueprint);
}

class QueryTaskAll extends BreezeQueryAll<Task> {
  QueryTaskAll({
    super.filter,
    super.autoUpdate,
  }) : super(blueprint: Task.blueprint);
}

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

final class _TaskColumns {
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
      BreezeModelColumn<int>(_TaskColumns.id, isPrimaryKey: true),
      BreezeModelColumn<String>(_TaskColumns.name),
      BreezeModelColumn<String?>(_TaskColumns.note),
      BreezeModelColumn<DateTime>(_TaskColumns.createdAt),
      BreezeModelColumn<XFile>(_TaskColumns.file),
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
    id: record[_TaskColumns.id],
    name: record[_TaskColumns.name] ?? 'n/a',
    note: record[_TaskColumns.note],
    createdAt: record[_TaskColumns.createdAt],
    file: record[_TaskColumns.file],
  );

  @override
  Map<String, dynamic> toRecord() => {
    _TaskColumns.id: id,
    _TaskColumns.name: name,
    _TaskColumns.note: note,
    _TaskColumns.createdAt: createdAt,
    _TaskColumns.file: file,
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
