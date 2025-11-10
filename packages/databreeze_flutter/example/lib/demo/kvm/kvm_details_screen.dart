import 'package:databreeze_flutter_example/demo/details_screen_mixin.dart';
import 'package:databreeze_flutter_example/demo/kvm/kvm_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KvmDetailsScreen extends StatefulWidget {
  final int id;

  const KvmDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  State<KvmDetailsScreen> createState() => _KvmDetailsScreenState();
}

class _KvmDetailsScreenState extends State<KvmDetailsScreen> with DetailsScreenMixin {
  @override
  late final int id = widget.id;

  @override
  late final store = context.read<KvmStore>();

  @override
  final String title = 'Breeze KVM Store';
}
