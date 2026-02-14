import 'package:databreeze_generator/src/code_generator.dart';
import 'package:databreeze_generator/src/types.dart';

class BlueprintSingleVersionGenerator extends CodeGenerator {
  final String className;
  final String tableName;
  final String primaryKey;
  final String primaryKeyType;
  final List<FieldInfo> fields;

  BlueprintSingleVersionGenerator({
    required this.className,
    required this.tableName,
    required this.primaryKey,
    required this.primaryKeyType,
    required this.fields,
  });

  @override
  Iterable<String> generate() sync* {
    final String output =
        '''
  static final blueprint = BreezeModelBlueprint<$className>(
    name: '$tableName',
    columns: {
      // id
      BreezeModelColumn<$primaryKeyType>('$primaryKey', isPrimaryKey: true),
${fields.map((f) => "\n// ${f.name}\n      BreezeModelColumn<${f.typeStr}>('${f.columnName}'),").join('\n')}
    },
    builder: ${className}Model.fromRecord,
  );
''';

    yield output;
  }
}
