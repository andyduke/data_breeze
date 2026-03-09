import 'package:databreeze_annotation/src/schema_version.dart';
import 'package:meta/meta_meta.dart';

enum BzModelNameStyle {
  /// Column names in the storage are in **snake_case** style.
  snakeCase,

  /// Column names in the storage are in **camelCase** style.
  camelCase,
}

@Target({TargetKind.classType})
class BzModel {
  final String? name;
  final String? primaryKey;
  final String? constructor;
  final Type? schemaVersionClass;
  final List<BzSchemaVersion> schemaHistory;
  // TODO: Rename [nameStyle] to [columnNameStyle]
  final BzModelNameStyle nameStyle;

  const BzModel({
    this.name,
    this.primaryKey,
    this.constructor,
    this.schemaVersionClass,
    this.schemaHistory = const [],
    this.nameStyle = BzModelNameStyle.snakeCase,
  });
}

@Target({TargetKind.field})
class BzColumn {
  final String name;

  const BzColumn({
    required this.name,
  });
}

@Target({TargetKind.field})
class BzRelationship {
  final String name;
  final String? foreignKey;
  final String? sourceKey;

  const BzRelationship._({
    required this.name,
    this.foreignKey,
    this.sourceKey,
  });

  const factory BzRelationship.hasOne({
    required String name,
    String? foreignKey,
    String? sourceKey,
  }) = BzRelationshipHasOne;

  const factory BzRelationship.hasMany({
    required String name,
    String? foreignKey,
    String? sourceKey,
  }) = BzRelationshipHasMany;

  const factory BzRelationship.belongsTo({
    required String name,
    String? foreignKey,
    String? sourceKey,
  }) = BzRelationshipBelongsTo;

  const factory BzRelationship.hasManyThrough({
    required String name,
    required String through,
    String? foreignKey,
    String? sourceKey,
  }) = BzRelationshipHasManyThrough;
}

class BzRelationshipHasOne extends BzRelationship {
  const BzRelationshipHasOne({
    required super.name,
    super.foreignKey,
    super.sourceKey,
  }) : super._();
}

class BzRelationshipHasMany extends BzRelationship {
  const BzRelationshipHasMany({
    required super.name,
    super.foreignKey,
    super.sourceKey,
  }) : super._();
}

class BzRelationshipBelongsTo extends BzRelationship {
  const BzRelationshipBelongsTo({
    required super.name,
    super.foreignKey,
    super.sourceKey,
  }) : super._();
}

class BzRelationshipHasManyThrough extends BzRelationship {
  final String through;

  const BzRelationshipHasManyThrough({
    required super.name,
    required this.through,
    super.foreignKey,
    super.sourceKey,
  }) : super._();
}

@Target({TargetKind.field, TargetKind.getter})
class BzTransient {
  const BzTransient();
}
