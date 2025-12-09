import 'package:databreeze_flutter_example/home_screen.dart';
import 'package:databreeze_flutter_example/demo/kvm/kvm_store.dart';
import 'package:databreeze_flutter_example/models/model_types.dart';
import 'package:databreeze_flutter_example/models/task.dart';
import 'package:databreeze_flutter_example/models/task_stats.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('[${record.loggerName}] ${record.time} ${record.level.name}: ${record.message}');
    }
  });

  runApp(BreezeExampleApp());
}

class BreezeExampleApp extends StatelessWidget {
  BreezeExampleApp({super.key});

  final kvmLog = Logger('KVM');
  final dbLog = Logger('Sqlite');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      builder: (context, child) => MultiProvider(
        providers: [
          // KVM Store
          Provider<KvmStore>(
            create: (context) => KvmStore(
              models: {
                Task.blueprint,
              },
              log: kvmLog,
            ),
            dispose: (context, store) => store.close(),
          ),

          // Sqlite store
          Provider<BreezeSqliteStore>(
            create: (context) => BreezeSqliteStore.inMemory(
              models: {
                Task.blueprint,
                TaskStatsModel.blueprint,
              },
              log: dbLog,
              migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
                log: dbLog,
              ),
              typeConverters: modelTypeConverters,
            ),
            dispose: (context, store) => store.close(),
          ),
        ],
        child: Material(
          child: child,
        ),
      ),
    );
  }
}
