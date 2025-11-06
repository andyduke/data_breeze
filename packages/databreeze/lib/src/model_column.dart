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
  final bool isAutoGenerate;

  /// The default value; NULL is replaced with this value
  /// both when writing and reading
  final T? defaultValue;

  /// Dart type in the model for this column
  Type get type => T;

  /// Does this column accept NULL values?
  bool get isNullable => null is T;

  const BreezeModelColumn(
    this.name, {
    this.prevName,
    this.isPrimaryKey = false,
    bool? isAutoGenerate,
    this.defaultValue,
  }) : isAutoGenerate = isAutoGenerate ?? (isPrimaryKey ? true : false);

  @override
  bool operator ==(covariant BreezeModelColumn<T> other) => name == other.name;

  @override
  int get hashCode => name.hashCode;
}
