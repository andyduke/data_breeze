import 'package:databreeze_flutter/src/data_result.dart';
import 'package:flutter/foundation.dart';

abstract class BreezeBaseDataController<T> extends ChangeNotifier {
  BreezeBaseDataController();

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
      final result = await doFetch(isReload);
      _result = BreezeResultSuccess<T>(result);
    } catch (error, stackTrace) {
      _result = BreezeResultError<T>(error, stackTrace);
    } finally {
      notifyListeners();
    }
  }

  Future<void> reload() => fetch(isReload: true);
}
