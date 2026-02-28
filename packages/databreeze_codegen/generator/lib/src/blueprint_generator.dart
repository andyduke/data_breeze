import 'package:databreeze_annotation/databreeze_annotation.dart';
import 'package:databreeze_generator/src/blueprint_multi_versions_generator.dart';
import 'package:databreeze_generator/src/blueprint_single_version_generator.dart';
import 'package:databreeze_generator/src/code_generator.dart';
import 'package:databreeze_generator/src/types.dart';

class BlueprintGenerator extends CodeGenerator {
  final String className;
  final String tableName;
  final String primaryKey;
  final String primaryKeyType;
  final List<FieldInfo> fields;
  final List<SchemaVersionChanges> schemaVersions;
  final String schemaVersionClass;
  final BzModelNameStyle nameStyle;

  BlueprintGenerator({
    required this.className,
    required this.tableName,
    required this.primaryKey,
    required this.primaryKeyType,
    required this.fields,
    required this.schemaVersions,
    required this.schemaVersionClass,
    required this.nameStyle,
  });

  @override
  Iterable<String> generate() sync* {
    if (schemaVersions.isEmpty) {
      final g = BlueprintSingleVersionGenerator(
        className: className,
        tableName: tableName,
        primaryKey: primaryKey,
        primaryKeyType: primaryKeyType,
        fields: fields,
      );
      yield* g.generate();
    } else {
      final g = BlueprintMultiVersionsGenerator(
        className: className,
        tableName: tableName,
        primaryKey: primaryKey,
        primaryKeyType: primaryKeyType,
        fields: fields,
        schemaVersions: schemaVersions,
        schemaVersionClass: schemaVersionClass,
        nameStyle: nameStyle,
      );
      yield* g.generate();
    }
  }
}
