import 'package:collection/collection.dart';
import 'package:databreeze_generator/src/code_generator.dart';
import 'package:databreeze_generator/src/types.dart';
import 'package:databreeze_generator/src/utils.dart';

class BlueprintMultiVersionsGenerator extends CodeGenerator {
  final String className;
  final String tableName;
  final String primaryKey;
  final String primaryKeyType;
  final List<FieldInfo> fields;
  final List<SchemaVersionChanges> schemaVersions;
  final String schemaVersionClass;

  BlueprintMultiVersionsGenerator({
    required this.className,
    required this.tableName,
    required this.primaryKey,
    required this.primaryKeyType,
    required this.fields,
    required this.schemaVersions,
    required this.schemaVersionClass,
  });

  @override
  Iterable<String> generate() sync* {
    final versions = _generateBlueprintVersions(tableName, primaryKey, schemaVersions);

    final output =
        '''
  static final blueprint = BreezeModelBlueprint<$className>.versioned(
    versions: {
      $versions
    },
    builder: ${className}Model.fromRecord,
  );
''';

    yield output;
  }

  String _generateBlueprintVersions(
    String tableName,
    String primaryKey,
    List<SchemaVersionChanges> schemaVersions,
  ) {
    final versions = generateVersionedColumns(fields, schemaVersions);

    final output = versions
        .map(
          (v) =>
              '''
      $schemaVersionClass(
        version: ${v.version},
        name: '$tableName',
        columns: {
          BreezeModelColumn<$primaryKeyType>('$primaryKey', isPrimaryKey: true),
${v.fields.map((f) => "         BreezeModelColumn<${f.typeStr}>(${f.constructorParams}),").join('\n')}
        },
      ),
''',
        )
        .join('\n');

    return output;
  }

  List<SchemaVersion> generateVersionedColumns(List<FieldInfo> fields, List<SchemaVersionChanges> versions) {
    final List<ColumnInfo> columns = fields
        .map(
          (f) => ColumnInfo(
            name: f.columnName ?? camelToSnake(f.name),
            type: f.typeStr,
            isNullable: f.isNullable,
          ),
        )
        .toList(growable: false);

    final blueprint = _generateSchemaVersions(columns, versions);

    return blueprint;
  }

  // ---

  List<ColumnInfo> _applyChanges(List<ColumnInfo> fields, List<SchemaFieldChange> changes) {
    final result = [...fields];

    for (final change in changes) {
      switch (change) {
        case SchemaAppendField(name: final name, type: final type, isNullable: final isNullable):
          final idx = result.indexWhere((f) => f.isSameName(name));
          if (idx == -1) {
            result.add(
              ColumnInfo(
                name: name,
                type: type.toString(),
                isNullable: isNullable,
              ),
            );
          }
          break;

        case SchemaRenameField(from: final from, to: final to):
          final idx = result.indexWhere((f) => f.isSameName(from));
          if (idx != -1) {
            result[idx] = result[idx].copyWith(name: to, prevName: from);
          }
          break;

        case SchemaDeleteField(name: final name):
          final idx = result.indexWhere((f) => f.isSameName(name));
          if (idx != -1) {
            result.removeAt(idx);
          }
          break;
      }
    }

    return result;
  }

  List<SchemaVersion> _generateSchemaVersions(List<ColumnInfo> fields, List<SchemaVersionChanges> versions) {
    List<ColumnInfo> currentFields = [];
    final result = <SchemaVersion>[];

    for (final version in versions) {
      final versionFields = _applyChanges(currentFields, version.changes);
      result.add(
        SchemaVersion(
          version: version.version, // TODO: Autoincrement version?
          fields: versionFields,
        ),
      );

      currentFields =
          versionFields //
              .map((f) => f.copyWith(prevName: CopyValue.reset()))
              .toList(growable: false);
    }

    return result;
  }
}
