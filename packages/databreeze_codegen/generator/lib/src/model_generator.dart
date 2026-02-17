import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';
import 'package:databreeze_generator/src/blueprint_generator.dart';
import 'package:databreeze_generator/src/blueprint_multi_versions_generator.dart';
import 'package:databreeze_generator/src/helpers.dart';
import 'package:databreeze_generator/src/types.dart';
import 'package:databreeze_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:databreeze_generator/src/dart_object_helpers.dart';

class BreezeModelGenerator extends GeneratorForAnnotation<BzModel> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) return null;

    final ClassElement classElement = element;
    final className = classElement.name!;
    final modelName = annotation.peek('name')?.stringValue;
    final tableName = modelName ?? camelToSnake(className);
    final primaryKey = annotation.peek('primaryKey')?.stringValue ?? 'id';
    final primaryKeyType = classElement.modelKeyType;
    final schemaVersionClass =
        annotation.peek('schemaVersionClass')?.typeValue.getDisplayString() ?? 'BreezeModelSchemaVersion';

    if (primaryKeyType == null) {
      throw Exception('The model\'s primary key type is not specified in BreezeModel<K>: $className.');
    }

    // Collect fields
    final fields = _collectFields(element, primaryKey: primaryKey);

    // Collect schema versions
    final schemaVersions = _collectSchemaVersions(element, annotation);

    // print('### $schemaVersions');

    // Validate the latest version against the list of fields
    _validateFieldsAgainstLatestSchema(
      fields,
      schemaVersions,
      className: className,
      tableName: tableName,
      primaryKey: primaryKey,
      primaryKeyType: primaryKeyType,
      schemaVersionClass: schemaVersionClass,
    );

    // Generate blueprint code
    final blueprint = _generateBlueprint(
      className,
      tableName,
      primaryKey,
      primaryKeyType,
      fields,
      schemaVersions,
      schemaVersionClass,
    ).join('\n');

    // Generate code
    final output =
        '''
mixin ${className}Model {
  $blueprint

  static $className fromRecord(Map<String, dynamic> map) => $className(
${fields.map((f) => "    ${f.constructorName}: map[${className}Model.${f.name}],").join('\n')}
  );

  static const id = BreezeField('$primaryKey');
${fields.map((f) => "  static const ${f.name} = BreezeField('${f.columnName}');").join('\n')}

  // ---

  $className get _self => this as $className;

  BreezeModelBlueprint get schema => ${className}Model.blueprint;

  Map<String, dynamic> toRecord() => {
${fields.map((f) => "    ${className}Model.${f.name}: _self.${f.accessorName},").join('\n')}
  };
}
''';

    // print(output);

    return output;
  }

  List<FieldInfo> _collectFields(ClassElement element, {required String primaryKey}) {
    final fields = <FieldInfo>[];

    /*
    for (final getter in element.getters) {
      if (getter.isPrivate || getter.isStatic || !getter.isOriginDeclaration) continue;

      if (element.lookUpSetter(name: getter.lookupName ?? getter.name!, library: element.library) != null) {
        // Get @BzColumn annotation
        final columnAnn = const TypeChecker.typeNamed(BzColumn).firstAnnotationOf(getter, throwOnUnresolved: false);
        final columnName = columnAnn == null
            ? camelToSnake(getter.name!)
            : ConstantReader(columnAnn).read('name').literalValue as String;

        // Skip transient fields from BreezeModel
        final transientAnn = const TypeChecker.typeNamed(
          BzTransient,
        ).firstAnnotationOf(getter, throwOnUnresolved: false);
        if (transientAnn != null) continue;

        print('[${element.displayName}] Getter: ${getter.name}, type: ${getter.returnType.element?.displayName}');

        // Add getter+setter as a model field
        fields.add(
          FieldInfo(
            name: getter.name!,
            typeStr: getter.returnType.element?.displayName ?? 'dynamic',
            isNullable: getter.returnType.nullabilitySuffix != NullabilitySuffix.none,
            columnName: columnName,
            isPrimaryKey: getter.name == primaryKey,
          ),
        );
      }
    }
    */

    for (final field in element.fields) {
      if (field.isStatic || // Skip Static fields
          (field.setter == null) // Skip readonly fields
          ) {
        continue;
      }

      // Get @BzColumn annotation
      final columnAnn = const TypeChecker.typeNamed(BzColumn).firstAnnotationOf(field, throwOnUnresolved: false);
      final columnName = (columnAnn == null)
          ? camelToSnake(field.name!)
          : ConstantReader(columnAnn).read('name').literalValue as String;

      // Skip a private property that does not have a field name annotation
      if (columnAnn == null && field.isPrivate) continue;

      // Skip transient fields from BreezeModel
      final transientAnn = const TypeChecker.typeNamed(BzTransient).firstAnnotationOf(field, throwOnUnresolved: false);
      if (transientAnn != null) continue;

      // print('[${element.displayName}] Prop: ${field.name}, type: ${field.type.element?.displayName}');

      final publicName = field.isPrivate ? field.name!.substring(1) : field.name!;

      // Add a class property as a model field
      fields.add(
        FieldInfo(
          constructorName: publicName,
          name: publicName,
          accessorName: field.name!,
          typeStr: field.type.element?.displayName ?? 'dynamic',
          isNullable: field.type.nullabilitySuffix != NullabilitySuffix.none,
          columnName: columnName,
          isPrimaryKey: field.name == primaryKey,
        ),
      );
    }

    return fields;
  }

  List<SchemaVersionChanges> _collectSchemaVersions(ClassElement element, ConstantReader annotation) {
    final versions = annotation.peek('schemaHistory')?.listValue ?? [];

    // print('### $versions');

    final result =
        versions //
            .map((v) => v.toSchemaVersion())
            .sortedByCompare((v) => v.version, (a, b) => a.compareTo(b));

    return result;
  }

  Iterable<String> _generateBlueprint(
    String className,
    String tableName,
    String primaryKey,
    String primaryKeyType,
    List<FieldInfo> fields,
    List<SchemaVersionChanges> schemaVersions,
    String schemaVersionClass,
  ) {
    final g = BlueprintGenerator(
      className: className,
      tableName: tableName,
      primaryKey: primaryKey,
      primaryKeyType: primaryKeyType,
      fields: fields,
      schemaVersions: schemaVersions,
      schemaVersionClass: schemaVersionClass,
    );
    return g.generate();
  }

  void _validateFieldsAgainstLatestSchema(
    List<FieldInfo> fields,
    List<SchemaVersionChanges> schemaVersions, {
    required String className,
    required String tableName,
    required String primaryKey,
    required String primaryKeyType,
    required String schemaVersionClass,
  }) {
    if (schemaVersions.isNotEmpty) {
      final blueprintGenerator = BlueprintMultiVersionsGenerator(
        className: className,
        tableName: tableName,
        primaryKey: primaryKey,
        primaryKeyType: primaryKeyType,
        fields: fields,
        schemaVersions: schemaVersions,
        schemaVersionClass: schemaVersionClass,
      );

      final schema = blueprintGenerator.generateVersionedColumns(fields, schemaVersions).lastOrNull;
      if (schema != null) {
        // Validate model fields against latest schema
        final schemaFieldNames = schema.fields.map((f) => f.name).toList(growable: false);
        final fieldNames = fields.map((f) => f.columnName).toList(growable: false);

        final missingFields = schemaFieldNames.where((e) => !fieldNames.contains(e));
        if (missingFields.isNotEmpty) {
          throw Exception('''The model "$className" fields do not match the schema.
The model is missing fields: ${missingFields.join(', ')}.''');
        }

        // print('### Fields: $fieldNames');
        // print('### Schema: $schemaFieldNames');

        final extraFields = fieldNames.where((e) => (e != primaryKey) && !schemaFieldNames.contains(e));
        if (extraFields.isNotEmpty) {
          throw Exception('''The model "$className" fields do not match the schema.
The schema does not specify the model fields: ${extraFields.join(', ')}.''');
        }
      }
    }
  }
}
