import 'package:databreeze_flutter/src/data_result.dart';
import 'package:flutter/foundation.dart';

typedef BreezeBaseDataControllerFilterDataCallback<T> = Future<T> Function(T data, bool isReload);
typedef BreezeBaseDataControllerDataCallback<T> = Future<void> Function(T data, bool isReload);
typedef BreezeBaseDataControllerErrorCallback = void Function(Object error, StackTrace? stackTrace);

abstract class BreezeBaseDataController<T> with ChangeNotifier {
  final BreezeBaseDataControllerFilterDataCallback<T>? onFilterData;
  final BreezeBaseDataControllerDataCallback<T>? onData;
  final BreezeBaseDataControllerErrorCallback? onError;

  BreezeBaseDataController({
    this.onFilterData,
    this.onData,
    this.onError,
  });

  bool get hasData => (data != null);

  T? get data => switch (result) {
    BreezeResultSuccess<T>(data: final data) => data,
    _ => null,
  };

  bool get hasError => (error != null);

  (Object error, StackTrace? stackTrace)? get error => switch (result) {
    BreezeResultError<T>(error: final error, stackTrace: final stackTrace) => (error, stackTrace),
    _ => null,
  };

  BreezeResult<T>? get result => _result;
  BreezeResult<T>? _result;

  @protected
  Future<T> doFetch([bool isReload = false]);

  Future<void> fetch({bool isReload = false}) async {
    if (!isReload) {
      _result = null;
      notifyListeners();
    }

    try {
      T result = await doFetch(isReload);

      if (onFilterData != null) {
        result = await onFilterData!(result, isReload);
      }

      _result = BreezeResultSuccess<T>(result);

      onData?.call(result, isReload);
    } catch (error, stackTrace) {
      _result = BreezeResultError<T>(error, stackTrace);

      onError?.call(error, stackTrace);
    } finally {
      notifyListeners();
    }
  }

  Future<void> reload() => fetch(isReload: true);
}
