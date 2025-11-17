import 'dart:async';
import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter/src/base_controller.dart';

class BreezeDataQueryController<T> extends BreezeBaseDataController<T> {
  final BreezeStore source;
  final bool autoUpdate;
  final bool refetchOnAutoUpdate;

  BreezeDataQueryController({
    required this.source,
    required BreezeQuery query,
    this.autoUpdate = true,
    this.refetchOnAutoUpdate = false,
    super.onFilterData,
    super.onData,
    super.onError,
  }) : _queryBuilder = (() => query);

  BreezeDataQueryController.builder({
    required this.source,
    required BreezeQuery Function() queryBuilder,
    this.autoUpdate = true,
    this.refetchOnAutoUpdate = false,
    super.onFilterData,
    super.onData,
    super.onError,
  }) : _queryBuilder = queryBuilder;

  final BreezeQuery Function() _queryBuilder;

  StreamSubscription<BreezeStoreChange>? _subscription;

  bool _autoUpdatePaused = false;

  @override
  Future<T> doFetch([bool isReload = false]) async {
    final query = _queryBuilder();
    final result = await query.fetch(source);

    if (autoUpdate) {
      // Subscribe to store changes
      _subscription ??= source.changes
          .where((event) => (event.store == source && query.autoUpdateWhen(event)))
          .listen(_sourceUpdated);
    }

    return result;
  }

  Future<void> _sourceUpdated(_) async {
    if (!_autoUpdatePaused) {
      await fetch(isReload: !refetchOnAutoUpdate);
    }
  }

  @override
  void dispose() {
    // Cancel store changes subscription
    _subscription?.cancel();

    super.dispose();
  }

  void pauseAutoUpdate() {
    if (autoUpdate) {
      _autoUpdatePaused = true;
    }
  }

  void resumeAutoUpdate({bool forceUpdate = false}) {
    if (autoUpdate) {
      _autoUpdatePaused = false;

      if (forceUpdate) {
        unawaited(
          _sourceUpdated(null),
        );
      }
    }
  }
}
