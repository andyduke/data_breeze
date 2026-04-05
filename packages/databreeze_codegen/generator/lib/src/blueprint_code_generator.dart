import 'package:databreeze_generator/src/code_generator.dart';
import 'package:databreeze_generator/src/types.dart';

abstract class BlueprintCodeGenerator extends CodeGenerator {
  String generateRelation(RelationInfo relation) {
    final result = StringBuffer('relations: {\n');

    result.writeln('BreezeModelRelation<${relation.type}>.${relation.relationType.name}(');
    result.writeln("  name: '${relation.name}',");

    if (relation.foreignKey != null) {
      result.writeln(
        "  foreignKey: BreezeRelationTypedKey('${relation.foreignKey!.name}', ${relation.foreignKey!.type}),",
      );
    }
    if (relation.sourceKey != null) {
      result.writeln(
        "  sourceKey: BreezeRelationTypedKey('${relation.sourceKey!.name}', ${relation.sourceKey!.type}),",
      );
    }
    if (relation.relationType == RelationType.hasManyThrough && relation.junction != null) {
      result.writeln("  junction: ${relation.junction},");
    }

    result.write('''),
}
''');

    return result.toString();
  }
}
