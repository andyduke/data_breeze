import 'dart:async';
import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter/src/base_controller.dart';
import 'package:flutter/foundation.dart';

class BreezeDataQueryController<T> extends BreezeBaseDataController<T> {
  final BreezeStore source;
  final bool refetchOnAutoUpdate;

  BreezeDataQueryController({
    required this.source,
    required BreezeQuery query,
    bool autoUpdate = true,
    this.refetchOnAutoUpdate = false,
    super.onFilterData,
    super.onData,
    super.onError,
  }) : _queryBuilder = (() => query) {
    _initialize(autoUpdate: autoUpdate);
  }

  BreezeDataQueryController.builder({
    required this.source,
    required BreezeQuery Function() queryBuilder,
    bool autoUpdate = true,
    this.refetchOnAutoUpdate = false,
    super.onFilterData,
    super.onData,
    super.onError,
  }) : _queryBuilder = queryBuilder {
    _initialize(autoUpdate: autoUpdate);
  }

  void _initialize({required bool autoUpdate}) {
    if (!autoUpdate) {
      pauseAutoUpdate();
    }
  }

  final BreezeQuery Function() _queryBuilder;

  StreamSubscription<BreezeStoreChange>? _subscription;

  bool _autoUpdatePaused = false;

  /// Were there any changes in the query source when
  /// there were no subscribers/watchers yet?
  bool _hasChanges = false;

  @override
  Future<T> doFetch([bool isReload = false]) async {
    final query = _queryBuilder();
    final result = await query.fetch(source);

    // Subscribe to store changes
    _subscription ??= source.changes
        .where((event) => (event.store == source && query.autoUpdateWhen(event)))
        .listen(_sourceUpdated);

    return result;
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    if (_hasChanges) {
      unawaited(
        _fetchData(force: true),
      );
    }
  }

  @protected
  bool get hasObservers => hasListeners;

  Future<void> _fetchData({bool force = false}) async {
    if (force || hasObservers) {
      _hasChanges = false;
      await fetch(isReload: !refetchOnAutoUpdate);
    } else {
      _hasChanges = true;
    }
  }

  Future<void> _sourceUpdated(_) async {
    if (!_autoUpdatePaused) {
      await _fetchData();
    }
  }

  @override
  void dispose() {
    _autoUpdatePaused = true;

    // Cancel store changes subscription
    _subscription?.cancel();
    _subscription = null;

    super.dispose();
  }

  void pauseAutoUpdate() {
    _autoUpdatePaused = true;
  }

  void resumeAutoUpdate({bool forceUpdate = false}) {
    _autoUpdatePaused = false;

    if (forceUpdate) {
      unawaited(
        _fetchData(),
      );
    }
  }
}
