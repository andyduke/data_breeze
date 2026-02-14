import 'package:analyzer/dart/constant/value.dart';
import 'package:databreeze_generator/src/types.dart';

extension DartObjectHelpers on DartObject {
  T decodeField<T>(
    String fieldName, {
    required T Function(DartObject obj) decode,
    required T Function() orElse,
  }) {
    final field = getField(fieldName);
    if (field == null || field.isNull) return orElse();
    return decode(field);
  }

  SchemaVersionChanges toSchemaVersion() {
    final version = decodeField(
      'version',
      decode: (v) => v.toIntValue() ?? 0,
      orElse: () => 0,
    );

    final changes = decodeField<List<SchemaFieldChange>>(
      'changes',
      decode: (c) => c.toListValue()?.map((e) => e.toSchemaChange()).toList(growable: false) ?? [],
      orElse: () => [],
    );

    return SchemaVersionChanges(
      version,
      changes,
    );
  }

  SchemaFieldChange toSchemaChange() {
    switch (type?.getDisplayString()) {
      case 'BzAppendField':
        return toAppendField();

      case 'BzRenameField':
        return toRenameField();

      case 'BzDeleteField':
        return toDeleteField();

      default:
        throw Exception('Type "$type" is not allowed here.');
    }
  }

  SchemaAppendField toAppendField() {
    final name = decodeField(
      'name',
      decode: (v) => v.toStringValue(),
      orElse: () => null,
    );
    final type = decodeField(
      'type',
      decode: (v) => v.toTypeValue(),
      orElse: () => null,
    );
    final isNullable =
        decodeField(
          'isNullable',
          decode: (v) => v.toBoolValue(),
          orElse: () => null,
        ) ??
        false;

    if (name == null) {
      throw Exception('No class field "name" specified in ".append": ${toString()}');
    }
    if (type == null) {
      throw Exception('No class field "type" specified in ".append": ${constructorInvocation.toString()}');
    }

    return SchemaAppendField(name, type.getDisplayString(), isNullable: isNullable);
  }

  SchemaRenameField toRenameField() {
    final fromName = decodeField(
      'from',
      decode: (v) => v.toStringValue(),
      orElse: () => null,
    );

    final toName = decodeField(
      'to',
      decode: (v) => v.toStringValue(),
      orElse: () => null,
    );

    if (fromName == null) {
      throw Exception('No class field "from" specified in ".rename".');
    }
    if (toName == null) {
      throw Exception('No class field "to" specified in ".rename".');
    }

    return SchemaRenameField(fromName, toName);
  }

  SchemaDeleteField toDeleteField() {
    final name = decodeField(
      'name',
      decode: (v) => v.toStringValue(),
      orElse: () => null,
    );

    if (name == null) {
      throw Exception('No class field "name" specified in ".delete".');
    }

    return SchemaDeleteField(name);
  }
}
