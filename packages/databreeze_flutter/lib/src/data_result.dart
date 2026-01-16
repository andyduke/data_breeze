import 'dart:async';
import 'package:collection/collection.dart';

// https://dartpad.dev/?id=b06a6b71203972a5332e6c2f7724bb93

typedef BreezeSuccessCallback<R, T> = R Function(T success);
typedef BreezeErrorCallback<R> = R Function(Object error, StackTrace? stackTrace);

abstract class BreezeResult<T> {
  bool get hasData;

  bool get hasError;

  const BreezeResult();

  const factory BreezeResult.pending() = BreezeResultPending;

  const factory BreezeResult.success(T data) = BreezeResultSuccess;

  const factory BreezeResult.error(Object error, [StackTrace? stackTrace]) = BreezeResultError;

  /*
  /// Wrap a [computation] function in a try/catch and return an [BreezeResult] with
  /// either a value or an error, based on whether an exception was thrown or not.
  static FutureOr<BreezeResult<T>> guard<T>(FutureOr<T> Function() computation) async {
    try {
      return BreezeResult.success(await computation());
    } catch (e, s) {
      return BreezeResult.error(e, s);
    }
  }

  /// Handle the result when success or error
  ///
  /// if the result is an error, it will be returned in [whenError]
  /// if it is a success it will be returned in [whenSuccess]
  R when<R>(
    BreezeSuccessCallback<R, T> whenSuccess,
    BreezeErrorCallback<R> whenError,
  );

  /// Execute [whenSuccess] if the [BreezeResult] is a success.
  R? whenSuccess<R>(
    BreezeSuccessCallback<R, T> whenSuccess,
  );

  /// Execute [whenError] if the [BreezeResult] is an error.
  R? whenError<R>(
    BreezeErrorCallback<R> whenError,
  );
  */
}

class BreezeResultPending<T> extends BreezeResult<T> {
  const BreezeResultPending();

  @override
  bool get hasData => false;

  @override
  bool get hasError => false;

  /*
  @override
  R when<R>(
    BreezeSuccessCallback<R, T> whenSuccess,
    BreezeErrorCallback<R> whenError,
  ) => whenSuccess();

  @override
  R whenSuccess<R>(BreezeSuccessCallback<R, T> whenSuccess) {
    return whenSuccess();
  }

  @override
  R? whenError<R>(BreezeErrorCallback<R> whenError) => null;
  */

  @override
  int get hashCode => null.hashCode;

  @override
  bool operator ==(covariant BreezeResult<T> other) {
    return (other is BreezeResultPending<T>);
  }
}

class BreezeResultSuccess<T> extends BreezeResult<T> {
  final T data;

  const BreezeResultSuccess(this.data);

  @override
  bool get hasData => true;

  @override
  bool get hasError => false;

  /*
  @override
  R when<R>(
    BreezeSuccessCallback<R, T> whenSuccess,
    BreezeErrorCallback<R> whenError,
  ) => whenSuccess(data);

  @override
  R whenSuccess<R>(BreezeSuccessCallback<R, T> whenSuccess) {
    return whenSuccess(data);
  }

  @override
  R? whenError<R>(BreezeErrorCallback<R> whenError) => null;
  */

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(covariant BreezeResultSuccess<T> other) {
    return other.data == data;
  }
}

class BreezeResultError<T> extends BreezeResult<T> {
  final Object error;
  final StackTrace? stackTrace;

  const BreezeResultError(
    this.error, [
    this.stackTrace,
  ]);

  @override
  bool get hasData => false;

  @override
  bool get hasError => true;

  /*
  @override
  R when<R>(
    BreezeSuccessCallback<R, T> whenSuccess,
    BreezeErrorCallback<R> whenError,
  ) => whenError(error, stackTrace);

  @override
  R? whenSuccess<R>(BreezeSuccessCallback<R, T> whenSuccess) => null;

  @override
  R whenError<R>(BreezeErrorCallback<R> whenError) => whenError(error, stackTrace);
  */

  @override
  int get hashCode => Object.hash(error, stackTrace);

  @override
  bool operator ==(covariant BreezeResultError<T> other) {
    return (other.error == error) && (other.stackTrace == stackTrace);
  }
}

// ---

extension BreezeResultList<T> on BreezeResult<List<T>> {
  T? find(bool Function(T entry) test) {
    if (this case BreezeResultSuccess<List<T>>(data: var list)) {
      return list.firstWhereOrNull(test);
    } else {
      return null;
    }
  }
}
