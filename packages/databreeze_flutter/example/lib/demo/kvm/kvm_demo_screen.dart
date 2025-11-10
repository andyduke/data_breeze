import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter_example/demo/demo_screen_mixin.dart';
import 'package:databreeze_flutter_example/demo/kvm/kvm_details_screen.dart';
import 'package:databreeze_flutter_example/demo/kvm/kvm_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KvmDemoScreen extends StatefulWidget {
  const KvmDemoScreen({
    super.key,
  });

  @override
  State<KvmDemoScreen> createState() => _KvmDemoScreenState();
}

class _KvmDemoScreenState extends State<KvmDemoScreen> with DemoScreenMixin {
  @override
  late final BreezeStore store = context.read<KvmStore>();

  @override
  final String title = 'Breeze Key-Value Memory Store';

  @override
  Future<void> showDetails(int id) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KvmDetailsScreen(id: id),
      ),
    );
  }
}
