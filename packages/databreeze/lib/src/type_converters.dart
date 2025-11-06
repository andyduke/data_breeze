abstract class BreezeBaseTypeConverter<DartType, StorageType> {
  const BreezeBaseTypeConverter();

  DartType toDart(StorageType value);

  StorageType toStorage(DartType value);

  bool isDartType(Type type) {
    final result = (type == DartType) || ((type == Null) && _isNullableType<DartType>());
    return result;
  }

  bool isStorageType(Type type) {
    final result = (type.toString() == StorageType.toString()) || ((type == Null) && _isNullableType<StorageType>());
    return result;
  }

  /// Checks whether the converter can convert the value to the specified Dart type.
  ///
  /// Note: It does not check the storage type, as this is unnecessary.
  bool canConvertToStorage(Type dartType) {
    final canConvert = isDartType(dartType);
    return canConvert;
  }

  /// Checks whether the converter can convert a value of the specified storage type to a Dart type.
  bool canConvertToDart(Type storageType, Type dartType) {
    final canConvert = isStorageType(storageType) && isDartType(dartType);
    return canConvert;
  }

  Type get dartType => DartType;

  Type get storageType => StorageType;

  bool _isType<T>(Type t) => t == T;
  bool _isNullableType<T>() => _isType<T?>(T);

  // TODO: Uniqueness is based solely on the Dart type, allowing you to override
  //  the converter for model blueprints.
  //  For example: for the entire SqliteStore, date storage is configured as INT,
  //  but for a specific model, you need to override the date storage to TEXT.
  @override
  bool operator ==(covariant BreezeBaseTypeConverter other) =>
      (dartType == other.dartType) && (storageType == other.storageType);

  @override
  int get hashCode => Object.hash(dartType, storageType);
}

class BreezeTypeConverter<DartType, StorageType> extends BreezeBaseTypeConverter<DartType, StorageType> {
  final DartType Function(StorageType value) from;
  final StorageType Function(DartType value) to;

  const BreezeTypeConverter({
    required this.from,
    required this.to,
  });

  @override
  DartType toDart(StorageType value) => from(value);

  @override
  StorageType toStorage(DartType value) => to(value);
}

mixin BreezeStorageTypeConverters {
  Set<BreezeBaseTypeConverter> get typeConverters;

  dynamic toDartValue(dynamic value, {required Type dartType, Set<BreezeBaseTypeConverter> converters = const {}}) {
    final storageType = value.runtimeType;
    final effectiveConverters = {
      ...typeConverters,
      ...converters,
    };

    for (final converter in effectiveConverters) {
      if (converter.canConvertToDart(storageType, dartType)) {
        return converter.toDart(value);
      }
    }
    return null;
  }

  dynamic toStorageValue(dynamic value, {required Type dartType, Set<BreezeBaseTypeConverter> converters = const {}}) {
    final effectiveConverters = {
      ...typeConverters,
      ...converters,
    };

    for (final converter in effectiveConverters) {
      if (converter.canConvertToStorage(dartType)) {
        return converter.toStorage(value);
      }
    }
    return null;
  }
}
