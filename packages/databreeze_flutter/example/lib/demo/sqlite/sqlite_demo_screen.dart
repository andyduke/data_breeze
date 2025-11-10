import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter_example/demo/demo_screen_mixin.dart';
import 'package:databreeze_flutter_example/demo/sqlite/sqlite_details_screen.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SqliteDemoScreen extends StatefulWidget {
  const SqliteDemoScreen({
    super.key,
  });

  @override
  State<SqliteDemoScreen> createState() => _SqliteDemoScreenState();
}

class _SqliteDemoScreenState extends State<SqliteDemoScreen> with DemoScreenMixin {
  @override
  late final BreezeStore store = context.read<BreezeSqliteStore>();

  @override
  final String title = 'Breeze Sqlite Store';

  @override
  Future<void> showDetails(int id) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SqliteDetailsScreen(id: id),
      ),
    );
  }
}
