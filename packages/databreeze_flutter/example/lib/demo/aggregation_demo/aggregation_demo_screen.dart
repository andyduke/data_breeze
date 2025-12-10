import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter/databreeze_flutter.dart';
import 'package:databreeze_flutter_example/demo/demo_screen_mixin.dart';
import 'package:databreeze_flutter_example/models/task_stats.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AggregationDemoScreen extends StatefulWidget {
  const AggregationDemoScreen({
    super.key,
  });

  @override
  State<AggregationDemoScreen> createState() => _AggregationDemoScreenState();
}

class _AggregationDemoScreenState extends State<AggregationDemoScreen> with DemoScreenMixin {
  @override
  late final BreezeStore store = context.read<BreezeSqliteStore>();

  /// Query controller with aggregate function
  late final countController = BreezeDataQueryController<TaskStats>(
    source: store,
    query: TaskStatsQuery(),
  );

  @override
  void dispose() {
    countController.dispose();

    super.dispose();
  }

  @override
  final String title = 'List with Aggregation Fn Demo';

  @override
  Future<void> showDetails(int id) async {
    // Do nothing
  }

  @override
  Widget? bottomBar() {
    return BreezeDataView(
      controller: countController,
      builder: (context, data) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text('Count: ${data.count}'),
      ),
    );
  }
}
