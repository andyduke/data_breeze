class BreezeModelColumn<T> {
  /// Column name in the database
  final String name;

  /// The previous name of the column in the database schema
  ///
  /// Used in a versioned schema when renaming a column.
  final String? prevName;

  /// Is the column a primary key?
  final bool isPrimaryKey;

  /// Are the values ​​in this column automatically generated
  /// in the database (e.g., auto-increment)?
  ///
  /// By default, the primary key is an auto-generated column.
  final bool isAutoGenerate;

  /// The default value; NULL is replaced with this value
  /// both when writing and reading
  final T? defaultValue;

  /// Dart type in the model for this column
  Type get type => T;

  /*
  /// The database data type for storing the column value
  ///
  /// In most cases, there is no need to specify this parameter,
  /// as it is determined automatically based on the default value
  /// type or column type.
  ///
  /// However, if the column type is non-standard (for example, an enum or object)
  /// and is converted using a type converter, you must specify the data
  /// type for its representation in the database.
  ///
  /// For example, for the enum type, you can specify `storageType: int`.
  @Deprecated('???')
  Type get storageType => _storageType ?? defaultValue?.runtimeType ?? type;
  final Type? _storageType;
  */

  /// Does this column accept NULL values?
  bool get isNullable => null is T;

  const BreezeModelColumn(
    this.name, {
    this.prevName,
    this.isPrimaryKey = false,
    bool? isAutoGenerate,
    this.defaultValue,
    // @Deprecated('???') Type? storageType,
  }) : isAutoGenerate = isAutoGenerate ?? (isPrimaryKey ? true : false)
  /* , _storageType = storageType */;

  @override
  bool operator ==(covariant BreezeModelColumn<T> other) => name == other.name;

  @override
  int get hashCode => name.hashCode;
}
