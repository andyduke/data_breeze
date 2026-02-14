import 'package:databreeze_generator/src/helpers.dart';
import 'package:databreeze_generator/src/utils.dart';

class FieldInfo {
  final String name;
  final String typeStr;
  final bool isNullable;
  final String? columnName;
  final bool isPrimaryKey;

  const FieldInfo({
    required this.name,
    required this.typeStr,
    required this.isNullable,
    this.columnName,
    this.isPrimaryKey = false,
  });
}

extension type const CopyValue(String str) implements String {
  const CopyValue.reset() : str = '~~~';
}

class ColumnInfo {
  final String name;
  final String? prevName;
  final String type;
  final bool isNullable;

  String get typeStr => type + (isNullable ? '?' : '');

  String get constructorParams => [
    name.quoted,
    if (prevName != null) 'prevName: ${prevName!.quoted}',
  ].join(', ');

  const ColumnInfo({
    required this.name,
    this.prevName,
    required this.type,
    this.isNullable = false,
  });

  ColumnInfo copyWith({
    String? name,
    String? prevName,
    String? type,
    bool? isNullable,
  }) {
    return ColumnInfo(
      name: name ?? this.name,
      prevName: (prevName == CopyValue.reset()) ? null : (prevName ?? this.prevName),
      type: type ?? this.type,
      isNullable: isNullable ?? this.isNullable,
    );
  }

  bool isSameName(String other) => name.toLowerCase() == other.toLowerCase();

  @override
  bool operator ==(covariant ColumnInfo other) =>
      (name == other.name) && (prevName == other.prevName) && (type == other.type) && (isNullable == other.isNullable);

  @override
  int get hashCode => Object.hash(name, prevName, type, isNullable);

  @override
  String toString() =>
      '$name: $type${(' (${[
        if (prevName != null) 'prev: $prevName',
        'isNullable: $isNullable',
      ].join(', ')})')}';
}

class SchemaVersion {
  final int version;
  final List<ColumnInfo> fields;

  const SchemaVersion({
    required this.version,
    required this.fields,
  });

  @override
  bool operator ==(covariant SchemaVersion other) => //
      (version == other.version) && (listEquals(fields, other.fields));

  @override
  int get hashCode => Object.hash(version, fields);

  @override
  String toString() =>
      '''_Version(
  version: $version,
  fields: $fields,
)''';
}

abstract class SchemaFieldChange {
  factory SchemaFieldChange.column(String name, Type type, {bool isNullable = false}) =>
      SchemaAppendField(name, type.toString(), isNullable: isNullable);

  factory SchemaFieldChange.rename(String name, {required String to}) => SchemaRenameField(name, to);

  const factory SchemaFieldChange.delete(String name) = SchemaDeleteField;
}

class SchemaAppendField implements SchemaFieldChange {
  final String name;
  final String type;
  final bool isNullable;

  const SchemaAppendField(
    this.name,
    this.type, {
    this.isNullable = false,
  });

  bool isSameName(String other) => name.toLowerCase() == other.toLowerCase();
}

class SchemaRenameField implements SchemaFieldChange {
  final String from;
  final String to;

  const SchemaRenameField(this.from, this.to);
}

class SchemaDeleteField implements SchemaFieldChange {
  final String name;

  const SchemaDeleteField(this.name);
}

class SchemaVersionChanges {
  final int version;
  final List<SchemaFieldChange> changes;

  const SchemaVersionChanges(this.version, this.changes);
}
