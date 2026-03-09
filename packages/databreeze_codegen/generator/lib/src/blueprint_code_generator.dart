import 'package:databreeze_generator/src/code_generator.dart';
import 'package:databreeze_generator/src/types.dart';

abstract class BlueprintCodeGenerator extends CodeGenerator {
  String generateRelation(RelationInfo relation) {
    final result = StringBuffer('relations: {\n');

    result.writeln('BreezeModelRelation<${relation.type}>.${relation.relationType.name}(');
    result.writeln("  name: '${relation.name}',");

    if (relation.foreignKey != null) {
      result.writeln("  foreignKey: '${relation.foreignKey}',");
    }
    if (relation.sourceKey != null) {
      result.writeln("  sourceKey: '${relation.sourceKey}',");
    }
    if (relation.relationType == RelationType.hasManyThrough && relation.through != null) {
      result.writeln("  through: '${relation.through}',");
    }

    result.write('''),
}
''');

    return result.toString();
  }
}
