import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/type_converters.dart';
import 'package:databreeze/src/types.dart';

class BreezeModelColumn<T> {
  final String name;
  final bool isPrimaryKey;
  final bool isAutoGenerate;

  /// Model type
  Type get type => T;

  // @protected
  bool get isNullable => null is T;

  const BreezeModelColumn(
    this.name, {
    this.isPrimaryKey = false,
    bool? isAutoGenerate,
    // this.isNullable = false,
  }) : isAutoGenerate = isAutoGenerate ?? (isPrimaryKey ? true : false);
}

class BreezeModelBlueprint<M extends BreezeModel> {
  static const defaultKey = 'id';

  final String name;
  final String key;
  final Map<String, BreezeModelColumn> columns;
  final M Function(BreezeDataRecord record) builder;

  BreezeModelBlueprint({
    required this.name,
    this.key = defaultKey,
    required List<BreezeModelColumn> columns,
    required this.builder,
  }) : columns = {
         for (final col in columns) col.name: col,
       };

  /// Create a model instance from a raw record
  T fromRecord<T>(Map<String, dynamic> record, BreezeStorageTypeConverters converters) =>
      ((T == M) ? builder(fromRaw(record, converters)) : record) as T;

  /// Convert db's data types to schema column types
  Map<String, dynamic> fromRaw(Map<String, dynamic> raw, BreezeStorageTypeConverters converters) =>
      raw.map((k, v) => MapEntry(k, valueFromStorage(k, v, converters)));

  /// Convert schema column types into db's data types
  Map<String, dynamic> toRaw(Map<String, dynamic> raw, BreezeStorageTypeConverters converters) =>
      raw.map((k, v) => MapEntry(k, valueToStorage(k, v, converters)));

  dynamic valueFromStorage(String name, dynamic value, BreezeStorageTypeConverters converters) {
    final column = columns[name]!;

    if (!column.isNullable && value == null) {
      throw Exception('[valueFromStorage] The value for column "$name" cannot be null.');
    }

    if (value == null) {
      return null;
    } else {
      final result = converters.toDartValue(
        value,
        dartType: column.type,
      );
      return result ?? value;
    }
  }

  dynamic valueToStorage(String name, dynamic value, BreezeStorageTypeConverters converters) {
    final column = columns[name]!;

    if (!column.isAutoGenerate && !column.isNullable && value == null) {
      throw Exception('[valueToStorage] The value for column "$name" cannot be null.');
    }

    if (value == null) {
      return null;
    } else {
      final result = converters.toStorageValue(
        value,
        dartType: column.type,
      );
      return result ?? value;
    }
  }
}
