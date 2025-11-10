import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter/databreeze_flutter.dart';
import 'package:databreeze_flutter_example/models/task.dart';
import 'package:flutter/material.dart';

mixin DetailsScreenMixin<T extends StatefulWidget> on State<T> {
  int get id;

  BreezeStore get store;

  String get title;

  // ---

  late final taskController = BreezeDataQueryController(
    source: store,
    query: BreezeQueryById<Task>(id),
    // refetchOnAutoUpdate: true,
  );

  @override
  void dispose() {
    taskController.dispose();

    super.dispose();
  }

  Future<void> updateTask(Task task) async {
    final store = taskController.source;

    task.name += '+';

    await store.save(task);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$title: Details'),
      ),
      body: BreezeDataView(
        controller: taskController,
        builder: (context, data) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Task name:', style: theme.textTheme.bodyLarge),

              const SizedBox(height: 8),
              Text('${data?.name}', style: theme.textTheme.titleLarge),

              const SizedBox(height: 32),
              FilledButton.tonal(
                onPressed: () => updateTask(data!),
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
