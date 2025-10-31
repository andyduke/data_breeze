import 'package:databreeze/src/store.dart';

enum BreezeStoreChangeType {
  add,
  update,
  delete,
}

class BreezeStoreChange {
  final BreezeStore store;
  final BreezeStoreChangeType type;
  final String entity;
  final dynamic id;

  const BreezeStoreChange({
    required this.store,
    required this.type,
    required this.entity,
    required this.id,
  });
}
