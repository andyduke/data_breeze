import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/sqlite_store.dart';

import '../model_types.dart';
import 'task.dart';

// Queries

class QueryAllTaskWithProgress extends BreezeQuery<TaskWithProgress, List<TaskWithProgress>> {
  final bool autoUpdate;

  QueryAllTaskWithProgress({
    super.blueprint,
    this.autoUpdate = true,
  });

  @override
  bool autoUpdateWhen(BreezeStoreChange change) =>
      autoUpdate && (change.entity == 'tasks' || change.entity == 'task_progress');

  @override
  Future<List<TaskWithProgress>> exec(covariant BreezeSqliteStore store) async {
    return store.fetchAllUsingSql<TaskWithProgress>(
      sql:
          'SELECT tasks.*, task_progress.progress AS progress '
          'FROM tasks LEFT JOIN task_progress ON tasks.id = task_progress.task_id '
          'GROUP BY tasks.id',
    );
  }
}

class TaskWithProgress extends Task {
  // TODO: How to inherit blueprint?
  static final blueprint = BreezeModelBlueprint<TaskWithProgress>(
    builder: TaskWithProgress.fromRecord,
    name: 'tasks',
    columns: [
      BreezeModelColumn<int>(TaskColumns.id, isPrimaryKey: true),
      BreezeModelColumn<String>(TaskColumns.name),
      BreezeModelColumn<String?>(TaskColumns.note),
      BreezeModelColumn<DateTime>(TaskColumns.createdAt),
      BreezeModelColumn<XFile>(TaskColumns.file),
      BreezeModelColumn<double?>('progress' /* transient: true - skip in migration */),
    ],
  );

  double? progress;

  TaskWithProgress({
    required super.name,
    super.note,
    super.createdAt,
    required super.file,
    this.progress,
  });

  factory TaskWithProgress.fromRecord(BreezeDataRecord record) => TaskWithProgress(
    name: record[TaskColumns.name] ?? 'n/a',
    note: record[TaskColumns.note],
    createdAt: record[TaskColumns.createdAt],
    file: record[TaskColumns.file],
    progress: record['progress'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    TaskColumns.name: name,
    TaskColumns.note: note,
    TaskColumns.createdAt: createdAt,
    TaskColumns.file: file,
    'progress': progress,
  };

  @override
  String toString() =>
      '''TaskWithProgress(
  id: $id,
  name: $name,
  note: ${note ?? '<null>'},
  createdAt: $createdAt,
  file: $file,
  progress: $progress
)''';
}
