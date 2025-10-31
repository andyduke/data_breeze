import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/store_change.dart';

abstract class BreezeQuery<T> {
  bool autoUpdateWhen(BreezeStoreChange change);

  Future<T> fetch(BreezeStore store);
}
