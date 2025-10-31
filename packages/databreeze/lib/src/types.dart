typedef BreezeDataRecord = Map<String, dynamic>;

class BreezeException implements Exception {
  final dynamic message;

  const BreezeException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "$runtimeType";
    return "$runtimeType: $message";
  }
}
