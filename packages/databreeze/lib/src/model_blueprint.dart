import 'dart:collection';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/type_converters.dart';
import 'package:databreeze/src/types.dart';

class BreezeModelColumn<T> {
  final String name;
  final bool isPrimaryKey;
  final bool isAutoGenerate;
  final T? defaultValue;

  /// Model type
  Type get type => T;

  // @protected
  bool get isNullable => null is T;

  const BreezeModelColumn(
    this.name, {
    this.isPrimaryKey = false,
    bool? isAutoGenerate,
    this.defaultValue,
    // this.isNullable = false,
  }) : isAutoGenerate = isAutoGenerate ?? (isPrimaryKey ? true : false);
}

class BreezeModelBlueprint<M extends BreezeAbstractModel> {
  static const defaultKey = 'id';

  final String name;
  final String key;
  final UnmodifiableMapView<String, BreezeModelColumn> columns;
  final M Function(BreezeDataRecord record) builder;
  final Set<BreezeBaseTypeConverter> typeConverters;

  BreezeModelBlueprint({
    required this.name,
    @Deprecated('Determine the key based on the column with the isPrimaryKey parameter.') this.key = defaultKey,
    required List<BreezeModelColumn> columns,
    required this.builder,
    this.typeConverters = const {},
  }) : columns = UnmodifiableMapView({
         for (final col in columns) col.name: col,
       });

  Type get type => M;

  /// Creates a copy of the model blueprint, changes the model type,
  /// and also allows you to modify other blueprint parameters.
  ///
  /// Note: Allows copying only for inherited models.
  BreezeModelBlueprint<T> extend<T extends M>({
    String? name,
    List<BreezeModelColumn>? columns,
    required T Function(Map<String, dynamic> raw) builder,
    Set<BreezeBaseTypeConverter>? typeConverters,
  }) {
    return BreezeModelBlueprint<T>(
      name: name ?? this.name,
      columns: columns ?? this.columns.values.toList(),
      builder: builder,
      typeConverters: typeConverters ?? this.typeConverters,
    );
  }

  /// Create a model instance from a raw record
  M fromRecord(Map<String, dynamic> record, BreezeStorageTypeConverters converters) {
    final typedRecord = fromRaw(record, converters);
    final result = builder(typedRecord);
    result.id = typedRecord[key];
    return result;
  }

  /// Convert db's data types to schema column types
  Map<String, dynamic> fromRaw(Map<String, dynamic> raw, BreezeStorageTypeConverters converters) =>
      raw.map((k, v) => MapEntry(k, valueFromStorage(k, v, converters)));

  /// Convert schema column types into db's data types
  Map<String, dynamic> toRaw(Map<String, dynamic> raw, BreezeStorageTypeConverters converters) =>
      raw.map((k, v) => MapEntry(k, valueToStorage(k, v, converters)));

  dynamic valueFromStorage(String name, dynamic value, BreezeStorageTypeConverters converters) {
    final column = columns[name];

    if (column == null) {
      return value;
    }

    if (!column.isNullable && value == null) {
      if (column.defaultValue != null) {
        return column.defaultValue;
      } else {
        throw Exception('[valueFromStorage] The value for column "$name" cannot be null.');
      }
    }

    if (value == null) {
      return null;
    } else {
      final result = converters.toDartValue(
        value,
        dartType: column.type,
        converters: typeConverters,
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
        converters: typeConverters,
      );
      return result ?? value;
    }
  }
}
