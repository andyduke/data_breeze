import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter_example/models/model_types.dart';
import 'package:flutter/foundation.dart';

final class _TaskColumns {
  static const id = 'id';
  static const name = 'name';
  static const note = 'note';
  static const createdAt = 'created_at';
  static const file = 'file';
}

class Task extends BreezeModel<int> with Diagnosticable {
  static final blueprint = BreezeModelBlueprint<Task>(
    name: 'tasks',
    columns: {
      BreezeModelColumn<int>(_TaskColumns.id, isPrimaryKey: true),
      BreezeModelColumn<String>(_TaskColumns.name),
      BreezeModelColumn<String?>(_TaskColumns.note),
      BreezeModelColumn<DateTime>(_TaskColumns.createdAt),
      BreezeModelColumn<XFile>(_TaskColumns.file),
    },
    builder: Task.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;
  String? note;
  DateTime createdAt;
  XFile file;

  Task({
    required this.name,
    this.note,
    DateTime? createdAt,
    required this.file,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Task.fromRecord(BreezeDataRecord raw) => Task(
    name: raw[_TaskColumns.name],
    note: raw[_TaskColumns.note],
    createdAt: raw[_TaskColumns.createdAt],
    file: raw[_TaskColumns.file],
  );

  @override
  Map<String, dynamic> toRecord() => {
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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('id', id));
    properties.add(StringProperty('name', name));
    properties.add(StringProperty('note', note));
    properties.add(DiagnosticsProperty<DateTime>('createdAt', createdAt));
    properties.add(DiagnosticsProperty<XFile>('file', file));
  }
}
