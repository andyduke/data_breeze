import 'package:databreeze_flutter/src/data_result.dart';
import 'package:flutter/foundation.dart';

abstract class BreezeBaseDataController<T> extends ChangeNotifier {
  BreezeBaseDataController();

  BreezeResult<T>? get data => _data;
  BreezeResult<T>? _data;

  @protected
  Future<T> doFetch([bool isReload = false]);

  Future<void> fetch({bool isReload = false}) async {
    if (!isReload) {
      _data = null;
      notifyListeners();
    }

    try {
      final result = await doFetch(isReload);
      _data = BreezeResultSuccess<T>(result);
    } catch (error, stackTrace) {
      _data = BreezeResultError<T>(error, stackTrace);
    } finally {
      notifyListeners();
    }
  }

  Future<void> reload() => fetch(isReload: true);
}
