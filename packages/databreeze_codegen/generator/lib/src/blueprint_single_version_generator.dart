import 'package:databreeze_generator/src/blueprint_code_generator.dart';
import 'package:databreeze_generator/src/types.dart';

class BlueprintSingleVersionGenerator extends BlueprintCodeGenerator {
  final String className;
  final String tableName;
  final String primaryKey;
  final String primaryKeyType;
  final List<FieldInfo> fields;
  final List<RelationInfo> relations;

  BlueprintSingleVersionGenerator({
    required this.className,
    required this.tableName,
    required this.primaryKey,
    required this.primaryKeyType,
    required this.fields,
    required this.relations,
  });

  @override
  Iterable<String> generate() sync* {
    // TODO: add relation columns generation
    final String output =
        '''
  static final blueprint = BreezeModelBlueprint<$className>(
    name: '$tableName',
    columns: {
      // id
      BreezeModelColumn<$primaryKeyType>('$primaryKey', isPrimaryKey: true),
${fields.map((f) => "\n// ${f.name}\n      BreezeModelColumn<${f.typeStr}>('${f.columnName}'),").join('\n')}
    },
    ${relations.isNotEmpty ? relations.map((r) => "\n  ${generateRelation(r)},").join('\n') : ''}
    builder: ${className}Model.fromRecord,
  );
''';

    yield output;
  }
}
