import 'package:databreeze_flutter/src/base_controller.dart';

typedef BreezeDataControllerFetcher<T> = Future<T> Function(bool isReload);

class BreezeDataFetchController<T> extends BreezeBaseDataController<T> {
  final BreezeDataControllerFetcher<T> onFetch;

  BreezeDataFetchController({
    required this.onFetch,
    super.onFilterData,
    super.onData,
    super.onError,
  });

  @override
  Future<T> doFetch([bool isReload = false]) async => await onFetch(isReload);
}
