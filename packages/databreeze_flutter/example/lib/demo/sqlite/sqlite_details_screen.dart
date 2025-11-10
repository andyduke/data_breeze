import 'package:databreeze_flutter_example/demo/details_screen_mixin.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SqliteDetailsScreen extends StatefulWidget {
  final int id;

  const SqliteDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  State<SqliteDetailsScreen> createState() => _SqliteDetailsScreenState();
}

class _SqliteDetailsScreenState extends State<SqliteDetailsScreen> with DetailsScreenMixin {
  @override
  late final int id = widget.id;

  @override
  late final store = context.read<BreezeSqliteStore>();

  @override
  final String title = 'Breeze Sqlite Store';
}
