import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';

mixin TaskStatsModel {
  static final blueprint = BreezeModelBlueprint<TaskStats>(
    name: 'tasks',
    columns: {
      BreezeModelColumn<int>(count),
    },
    builder: fromRecord,
  );

  static TaskStats fromRecord(Map<String, dynamic> map) => TaskStats(
    count: map[count],
  );

  static const count = BreezeField('count');
}

class TaskStats extends BreezeViewModel with TaskStatsModel {
  final int count;

  TaskStats({
    required this.count,
  });
}

class TaskStatsQuery extends BreezeQueryWhere<TaskStats> {
  TaskStatsQuery({
    super.blueprint,
    super.autoUpdate,
  }) : super(null);

  @override
  Future<TaskStats?> exec(covariant BreezeSqliteStore store) async {
    return store.count('tasks', 'id').then((value) => TaskStatsModel.blueprint.fromRecord({'count': value}, store));
  }
}
