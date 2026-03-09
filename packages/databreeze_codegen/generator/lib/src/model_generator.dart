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
    final tableName =
        modelName ??
        camelToSnake(
          className,
        ); // TODO: plural - https://github.com/ivofernandes/pluralize/blob/main/lib/src/pluralize.dart
    final primaryKey = annotation.peek('primaryKey')?.stringValue ?? 'id';
    final primaryKeyType = classElement.modelKeyType;
    final constructor = annotation.peek('constructor')?.stringValue;
    final nameStyle = BzModelNameStyleUtils.fromString(annotation.peek('nameStyle')?.revive().accessor);
    final schemaVersionClass =
        annotation.peek('schemaVersionClass')?.typeValue.getDisplayString() ?? 'BreezeModelSchemaVersion';

    if (primaryKeyType == null) {
      throw Exception('The model\'s primary key type is not specified in BreezeModel<K>: $className.');
    }

    // Collect fields
    final fields = _collectFields(element, primaryKey: primaryKey, nameStyle: nameStyle);

    // Collect relations
    final relations = _collectRelations(element, primaryKey: primaryKey, nameStyle: nameStyle);

    // Collect schema versions
    final schemaVersions = _collectSchemaVersions(element, annotation);

    // print('### $schemaVersions');

    // Validate the latest version against the list of fields
    _validateFieldsAgainstLatestSchema(
      fields,
      relations,
      schemaVersions,
      className: className,
      tableName: tableName,
      primaryKey: primaryKey,
      primaryKeyType: primaryKeyType,
      schemaVersionClass: schemaVersionClass,
      nameStyle: nameStyle,
    );

    // Generate blueprint code
    final blueprint = _generateBlueprint(
      className,
      tableName,
      primaryKey,
      primaryKeyType,
      fields,
      relations,
      schemaVersions,
      schemaVersionClass,
      nameStyle,
    ).join('\n');

    // Generate code
    final constructorName = (constructor != null && constructor.isNotEmpty) ? '.$constructor' : '';
    final primaryKeyProp = snakeToCamel(primaryKey);
    final output =
        '''
mixin ${className}Model {
  $blueprint

  static $className fromRecord(Map<String, dynamic> map) => $className$constructorName(
${fields.map((f) => "    ${f.constructorName}: map[${className}Model.${f.name}],").join('\n')}
${relations.map((r) => "    ${r.name}: map['${r.name}'],").join('\n')}
  );

  static const $primaryKeyProp = BreezeField('$primaryKey');
${fields.where((f) => f.columnName != primaryKey).map((f) => "  static const ${f.name} = BreezeField('${f.columnName}');").join('\n')}

  // ---

  $className get _self => this as $className;

  BreezeModelBlueprint get schema => ${className}Model.blueprint;

  Map<String, dynamic> toRecord() => {
${fields.map((f) => "    ${className}Model.${f.name}: _self.${f.accessorName},").join('\n')}
${relations.map((r) => "    '${r.name}': _self.${r.name},").join('\n')}
  };
}
''';

    // print(output);

    return output;
  }

  List<FieldInfo> _collectFields(
    ClassElement element, {
    required String primaryKey,
    required BzModelNameStyle nameStyle,
  }) {
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

      if (field.name == 'id') continue;

      final annotationField = field.isOriginGetterSetter ? field.getter! : field;

      // Skip relationship fields from BreezeModel
      final relationshipAnn = const TypeChecker.typeNamed(
        BzRelationship,
      ).firstAnnotationOf(annotationField, throwOnUnresolved: false);
      if (relationshipAnn != null) continue;

      // Get @BzColumn annotation
      final columnAnn = const TypeChecker.typeNamed(
        BzColumn,
      ).firstAnnotationOf(annotationField, throwOnUnresolved: false);
      final columnName = (columnAnn == null)
          ? convertNameStyle(field.name!, nameStyle)
          : ConstantReader(columnAnn).read('name').literalValue as String;

      // Skip a private property that does not have a field name annotation
      if (columnAnn == null && field.isPrivate) continue;

      // Skip transient fields from BreezeModel
      final transientAnn = const TypeChecker.typeNamed(
        BzTransient,
      ).firstAnnotationOf(annotationField, throwOnUnresolved: false);
      if (transientAnn != null) continue;

      // print(
      //   '[${element.displayName}] Prop: ${field.name}, type: ${field.type.getDisplayString() /*element?.displayName*/}, nullable: ${field.type.nullabilitySuffix}',
      // );

      final publicName = field.isPrivate ? field.name!.substring(1) : field.name!;

      // Add a class property as a model field
      fields.add(
        FieldInfo(
          constructorName: publicName,
          name: publicName,
          accessorName: field.name!,
          type: field.type.getDisplayString() /*field.type.element?.displayName ?? 'dynamic'*/,
          isNullable: field.type.nullabilitySuffix != NullabilitySuffix.none,
          columnName: columnName,
          isPrimaryKey: field.name == primaryKey,
        ),
      );
    }

    return fields;
  }

  List<RelationInfo> _collectRelations(
    ClassElement element, {
    required String primaryKey,
    required BzModelNameStyle nameStyle,
  }) {
    final result = <RelationInfo>[];

    for (final field in element.fields) {
      if (field.isStatic || // Skip Static fields
          field.isPrivate || // Skip Private fields
          (field.setter == null) // Skip readonly fields
          ) {
        continue;
      }

      final annotationField = field.isOriginGetterSetter ? field.getter! : field;

      // Get @BzRelationship annotation
      final relationAnn = const TypeChecker.typeNamed(
        BzRelationship,
      ).firstAnnotationOf(annotationField, throwOnUnresolved: false);

      if (relationAnn == null) continue;

      final relationAnnReader = ConstantReader(relationAnn);
      final relationType = RelationType.fromString(relationAnn.constructorInvocation!.constructor.name!);
      final relationName = relationAnnReader.read('name').literalValue as String;
      final relationModelType = switch (relationType) {
        RelationType.hasOne => field.type.getDisplayString(),
        RelationType.hasMany => field.type.genericTypes.first.getDisplayString(),
        RelationType.belongsTo => field.type.getDisplayString(),
        RelationType.hasManyThrough => field.type.genericTypes.first.getDisplayString(),
      }.replaceFirst('?', '');
      final relationForeignKey = relationAnnReader.read('foreignKey').literalValue as String?;
      final relationSourceKey = relationAnnReader.read('sourceKey').literalValue as String?;
      final relationThrough = relationAnnReader.peek('through')?.literalValue as String?;

      print(
        '[!] $relationType (${field.type.isDartCoreList ? field.type.genericTypes : '--'}): $relationName<$relationModelType> (foreignKey: $relationForeignKey, sourceKey: $relationSourceKey)',
      );

      // print(
      //   '[${element.displayName}] Prop: ${field.name}, type: ${field.type.getDisplayString() /*element?.displayName*/}, nullable: ${field.type.nullabilitySuffix}',
      // );

      result.add(
        RelationInfo(
          name: relationName,
          relationType: relationType,
          type: relationModelType,
          foreignKey: relationForeignKey,
          sourceKey: relationSourceKey,
          through: relationThrough,
        ),
      );
    }

    return result;
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
    List<RelationInfo> relations,
    List<SchemaVersionChanges> schemaVersions,
    String schemaVersionClass,
    BzModelNameStyle nameStyle,
  ) {
    final g = BlueprintGenerator(
      className: className,
      tableName: tableName,
      primaryKey: primaryKey,
      primaryKeyType: primaryKeyType,
      fields: fields,
      relations: relations,
      schemaVersions: schemaVersions,
      schemaVersionClass: schemaVersionClass,
      nameStyle: nameStyle,
    );
    return g.generate();
  }

  void _validateFieldsAgainstLatestSchema(
    List<FieldInfo> fields,
    List<RelationInfo> relations,
    List<SchemaVersionChanges> schemaVersions, {
    required String className,
    required String tableName,
    required String primaryKey,
    required String primaryKeyType,
    required String schemaVersionClass,
    required BzModelNameStyle nameStyle,
  }) {
    if (schemaVersions.isNotEmpty) {
      final blueprintGenerator = BlueprintMultiVersionsGenerator(
        className: className,
        tableName: tableName,
        primaryKey: primaryKey,
        primaryKeyType: primaryKeyType,
        fields: fields,
        relations: relations,
        schemaVersions: schemaVersions,
        schemaVersionClass: schemaVersionClass,
        nameStyle: nameStyle,
      );

      final schema = blueprintGenerator.generateVersionedColumns(fields, schemaVersions).lastOrNull;
      if (schema != null) {
        // Validate model fields against latest schema
        final schemaFieldNames = schema.fields.map((f) => f.name).toList(growable: false);
        final fieldNames = fields.map((f) => f.columnName).toList(growable: false);

        final primaryKeyDetected = schemaFieldNames.contains(primaryKey);
        if (primaryKeyDetected) {
          throw Exception('''The model "$className" schema must not specify a primary key field "$primaryKey".''');
        }

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

extension BzModelNameStyleUtils on BzModelNameStyle {
  static BzModelNameStyle fromString(
    String? value, {
    BzModelNameStyle defaultValue = BzModelNameStyle.snakeCase,
  }) {
    if (value != null) {
      final valueName = value.split('.').last;
      final result = BzModelNameStyle.values.firstWhereOrNull((v) => v.name == valueName);
      return result ?? defaultValue;
    } else {
      return defaultValue;
    }
  }
}
