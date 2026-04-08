import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:meta/meta.dart';

class BreezeRelationTypedKey {
  final String name;

  final Type type;

  const BreezeRelationTypedKey(
    this.name,
    this.type,
  );

  // static BreezeRelationKey typed<T extends Object>(String key) => BreezeRelationKey(key, T);
}

class BreezeRelationKey<T> extends BreezeRelationTypedKey {
  @override
  Type get type => T;

  const BreezeRelationKey(
    String name,
  ) : super(name, T);

  const factory BreezeRelationKey.key(String name) = BreezeRelationKey;
}

enum BreezeRelationshipDeleteRule {
  nullify,
  cascade,
}

@protected
sealed class BreezeModelRelation<M extends BreezeBaseModel> {
  /// Column alias
  final String name;

  // TODO: Rename to referenceKey
  /// Foreign key
  final BreezeRelationTypedKey? foreignKey;

  /// Primary key
  ///
  /// Default: modelBlueprint.key
  final BreezeRelationTypedKey? sourceKey;

  /// The rule to apply when you delete the
  /// relationship's owning model.
  final BreezeRelationshipDeleteRule deleteRule;

  Type get type => M;

  const BreezeModelRelation({
    required this.name,
    required this.foreignKey,
    this.sourceKey,
    this.deleteRule = BreezeRelationshipDeleteRule.nullify,
  });

  factory BreezeModelRelation.hasOne({
    required String name,
    BreezeRelationTypedKey? foreignKey,
    BreezeRelationTypedKey? sourceKey,
    BreezeRelationshipDeleteRule deleteRule,
  }) = BreezeModelHasOneRelation;

  factory BreezeModelRelation.hasMany({
    required String name,
    BreezeRelationTypedKey? foreignKey,
    BreezeRelationTypedKey? sourceKey,
    BreezeRelationshipDeleteRule deleteRule,
  }) = BreezeModelHasManyRelation;

  factory BreezeModelRelation.belongsTo({
    required String name,
    BreezeRelationTypedKey? foreignKey,
    BreezeRelationTypedKey? sourceKey,
  }) = BreezeModelBelongsToRelation;

  factory BreezeModelRelation.hasManyThrough({
    required String name,
    // required String junction,
    required Type junction,
    BreezeRelationTypedKey? foreignKey,
    BreezeRelationTypedKey? sourceKey,
  }) = BreezeModelHasManyThroughRelation;
}

final class BreezeModelHasOneRelation<M extends BreezeBaseModel> extends BreezeModelRelation<M> {
  BreezeModelHasOneRelation({
    required super.name,
    super.foreignKey,
    super.sourceKey,
    super.deleteRule,
  });
}

final class BreezeModelHasManyRelation<M extends BreezeBaseModel> extends BreezeModelRelation<M> {
  BreezeModelHasManyRelation({
    required super.name,
    super.foreignKey,
    super.sourceKey,
    super.deleteRule,
  });
}

final class BreezeModelBelongsToRelation<M extends BreezeBaseModel> extends BreezeModelRelation<M> {
  BreezeModelBelongsToRelation({
    required super.name,
    super.foreignKey,
    super.sourceKey,
  });
}

final class BreezeModelHasManyThroughRelation<M extends BreezeBaseModel> extends BreezeModelRelation<M> {
  // TODO: The junction collection must be represented by a model
  //  so that a versioned schema can be described for it.
  // final String junction;
  final Type junction;

  BreezeModelHasManyThroughRelation({
    required super.name,
    required this.junction,

    /// self model key inside intermediate table
    /// '<source>_id'
    super.foreignKey,

    /// target model key inside intermediate table
    /// '<target>_id'
    super.sourceKey,
  });
}

// --- Resolved Relation Info

sealed class BreezeModelResolvedRelation /*<M extends BreezeBaseModel>*/ {
  /// Column alias
  final String name;

  /// Foreign key
  final BreezeRelationTypedKey foreignKey;

  /// Primary key
  final BreezeRelationTypedKey sourceKey;

  final BreezeRelationshipDeleteRule deleteRule;

  // Type get type => M;
  final Type type;

  const BreezeModelResolvedRelation({
    required this.type,
    required this.name,
    required this.foreignKey,
    required this.sourceKey,
    required this.deleteRule,
  });
}

final class BreezeModelResolvedHasOneRelation /*<M extends BreezeBaseModel>*/
    extends BreezeModelResolvedRelation /*<M>*/ {
  const BreezeModelResolvedHasOneRelation({
    required super.type,
    required super.name,
    required super.foreignKey,
    required super.sourceKey,
    required super.deleteRule,
  });
}

final class BreezeModelResolvedHasManyRelation /*<M extends BreezeBaseModel>*/
    extends BreezeModelResolvedRelation /*<M>*/ {
  const BreezeModelResolvedHasManyRelation({
    required super.type,
    required super.name,
    required super.foreignKey,
    required super.sourceKey,
    required super.deleteRule,
  });
}

final class BreezeModelResolvedBelongsToRelation /*<M extends BreezeBaseModel>*/
    extends BreezeModelResolvedRelation /*<M>*/ {
  const BreezeModelResolvedBelongsToRelation({
    required super.type,
    required super.name,
    required super.foreignKey,
    required super.sourceKey,
    required super.deleteRule,
  });
}

final class BreezeModelResolvedHasManyThroughRelation /*<M extends BreezeBaseModel>*/
    extends BreezeModelResolvedRelation /*<M>*/ {
  final String leftPk;
  final BreezeModelBlueprint junction;

  const BreezeModelResolvedHasManyThroughRelation({
    required super.type,
    required super.name,
    required this.junction,
    required this.leftPk,
    required BreezeRelationTypedKey leftKey,
    required BreezeRelationTypedKey rightKey,
  }) : super(foreignKey: leftKey, sourceKey: rightKey, deleteRule: BreezeRelationshipDeleteRule.nullify);
}
