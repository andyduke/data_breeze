import 'dart:typed_data';
import 'package:databreeze/databreeze.dart';
import 'package:sqlite_async/sqlite3_common.dart';

typedef BreezeSqliteJsonB = Uint8List;

class BreezeSqliteJsonListConverter<T> extends BreezeTypeConverter<List<T>, BreezeSqliteJsonB> {
  @override
  List<T> toDart(BreezeSqliteJsonB value) {
    final decoded = jsonb.decode(value);

    if (decoded is List) {
      try {
        return decoded.cast<T>().toList();
      } on TypeError catch (e) {
        throw Exception('[JsonListConverter] ${decoded.runtimeType} is not a List<$T>: $e');
      }
    } else {
      throw Exception('[JsonListConverter] ${decoded.runtimeType} is not a List<$T>.');
    }
  }

  @override
  BreezeSqliteJsonB toStorage(List<T> value) => jsonb.encode(value);
}
