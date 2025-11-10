import 'dart:async';
import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter/src/base_controller.dart';

class BreezeDataQueryController<T> extends BreezeBaseDataController<T> {
  final BreezeStore source;
  final BreezeQuery query;
  final bool autoUpdate;
  final bool refetchOnAutoUpdate;

  BreezeDataQueryController({
    required this.source,
    required this.query,
    this.autoUpdate = true,
    this.refetchOnAutoUpdate = false,
  });

  StreamSubscription<BreezeStoreChange>? _subscription;

  @override
  Future<T> doFetch([bool isReload = false]) async {
    final result = await query.fetch(source);

    if (autoUpdate) {
      // Subscribe to store changes
      _subscription ??= source.changes
          .where((event) => (event.store == source && query.autoUpdateWhen(event)))
          .listen(
            (_) => fetch(isReload: !refetchOnAutoUpdate),
          );
    }

    return result;
  }

  @override
  void dispose() {
    // Cancel store changes subscription
    _subscription?.cancel();

    super.dispose();
  }
}
