import 'package:databreeze/databreeze.dart';

final class TaskProgressColumns {
  static const id = 'task_id';
  static const progress = 'progress';
}

class TaskProgress extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint<TaskProgress>(
    builder: TaskProgress.fromRecord,
    name: 'task_progress',
    columns: {
      BreezeModelColumn<int>(TaskProgressColumns.id, isPrimaryKey: true),
      BreezeModelColumn<double>(TaskProgressColumns.progress),
    },
    tags: {
      #temporary,
    },
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  double progress;

  TaskProgress({
    int? id,
    required this.progress,
  }) {
    this.id = id;
  }

  factory TaskProgress.fromRecord(BreezeDataRecord record) => TaskProgress(
    progress: record[TaskProgressColumns.progress],
  );

  @override
  Map<String, dynamic> toRecord() => {
    TaskProgressColumns.progress: progress,
  };

  @override
  String toString() =>
      '''TaskProgress(
  task_id: $id,
  progress: $progress
)''';
}
