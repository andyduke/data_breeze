// ignore_for_file: avoid_print

import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter/databreeze_flutter.dart';
import 'package:databreeze_flutter_example/models/model_types.dart';
import 'package:databreeze_flutter_example/models/task.dart';
import 'package:flutter/material.dart';

mixin DemoScreenMixin<T extends StatefulWidget> on State<T> {
  BreezeStore get store;

  String get title;

  Future<void> showDetails(int id);

  // ---

  int taskNum = 1;

  final adding = ValueNotifier(false);

  late final tasksController = BreezeDataQueryController(
    source: store,
    query: BreezeQueryAll<Task>(),
    // refetchOnAutoUpdate: true,
  );

  @override
  void dispose() {
    tasksController.dispose();

    super.dispose();
  }

  Future<void> addTask() async {
    // final store = store;
    final store = tasksController.source;

    var task = Task(
      name: 'Task ${taskNum++}',
      file: XFile('path/to/file'),
    );

    adding.value = true;
    try {
      final newTask = await store.save(task);

      print('### New task id: ${newTask.id}');
    } finally {
      adding.value = false;
    }
  }

  Future<void> updateTask(Task task) async {
    // final store = store;
    final store = tasksController.source;

    task.name += '*';

    await store.save(task);
  }

  Future<void> deleteTask(Task task) async {
    // final store = store;
    final store = tasksController.source;

    await store.delete(task);
  }

  Widget? bottomBar() => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ValueListenableBuilder(
            valueListenable: adding,
            builder: (context, value, child) {
              return !value
                  ? IconButton.filledTonal(
                      onPressed: addTask,
                      icon: Icon(Icons.add),
                    )
                  : IconButton.filledTonal(
                      onPressed: null,
                      icon: SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(),
                      ),
                    );
            },
          ),
        ],
      ),
      body: BreezeDataView(
        controller: tasksController,
        builder: (context, data) => RefreshIndicator.adaptive(
          onRefresh: () => tasksController.reload(),
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => ListTile(
              onTap: () {
                showDetails(data[index].id!);
              },
              title: Text('#${data[index].id} ${data[index].name}'),
              trailing: OverflowBar(
                children: [
                  IconButton(
                    onPressed: () => updateTask(data[index]),
                    icon: Icon(Icons.text_increase),
                  ),

                  IconButton(
                    onPressed: () => deleteTask(data[index]),
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar(),
    );
  }
}
