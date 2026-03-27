import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:meta/meta.dart';

@protected
sealed class BreezeModelRelation<M extends BreezeBaseModel> {
  /// Column alias
  final String name;

  /// Foreign key
  final String? foreignKey;

  /// Primary key
  ///
  /// Default: modelBlueprint.key
  final String? sourceKey;

  Type get type => M;

  const BreezeModelRelation({
    required this.name,
    required this.foreignKey,
    this.sourceKey,
  });

  factory BreezeModelRelation.hasOne({
    required String name,
    required String? foreignKey,
    String? sourceKey,
  }) = BreezeModelHasOneRelation;

  factory BreezeModelRelation.hasMany({
    required String name,
    required String? foreignKey,
    String? sourceKey,
  }) = BreezeModelHasManyRelation;

  factory BreezeModelRelation.belongsTo({
    required String name,
    String? foreignKey,
    required String? sourceKey,
  }) = BreezeModelBelongsToRelation;

  factory BreezeModelRelation.hasManyThrough({
    required String name,
    required String through,
    String? foreignKey,
    String? sourceKey,
  }) = BreezeModelHasManyThroughRelation;

  @Deprecated('Use BreezeStoreRelations.resolveRelation instead.')
  BreezeModelResolvedRelation<M> resolve<P extends BreezeBaseModel>(BreezeModelBlueprint<P> blueprint);
}

final class BreezeModelHasOneRelation<M extends BreezeBaseModel> extends BreezeModelRelation<M> {
  BreezeModelHasOneRelation({
    required super.name,
    required super.foreignKey,
    super.sourceKey,
  });

  @override
  BreezeModelResolvedRelation<M> resolve<P extends BreezeBaseModel>(BreezeModelBlueprint<P> blueprint) {
    final table = blueprint.name;
    final pk = blueprint.key;

    return BreezeModelResolvedHasOneRelation<M>(
      name: name,
      foreignKey: foreignKey ?? '${table}_$pk',
      sourceKey: sourceKey ?? 'id',
    );
  }
}

final class BreezeModelHasManyRelation<M extends BreezeBaseModel> extends BreezeModelRelation<M> {
  BreezeModelHasManyRelation({
    required super.name,
    required super.foreignKey,
    super.sourceKey,
  });

  @override
  BreezeModelResolvedRelation<M> resolve<P extends BreezeBaseModel>(BreezeModelBlueprint<P> blueprint) {
    final table = blueprint.name;
    final pk = blueprint.key;

    return BreezeModelResolvedHasManyRelation(
      name: name,
      foreignKey: foreignKey ?? '${table}_$pk',
      sourceKey: sourceKey ?? 'id',
    );
  }
}

final class BreezeModelBelongsToRelation<M extends BreezeBaseModel> extends BreezeModelRelation<M> {
  BreezeModelBelongsToRelation({
    required super.name,
    super.foreignKey,
    required super.sourceKey,
  });

  @override
  BreezeModelResolvedRelation<M> resolve<P extends BreezeBaseModel>(BreezeModelBlueprint<P> blueprint) {
    final pk = blueprint.key;

    return BreezeModelResolvedBelongsToRelation(
      name: name,
      foreignKey: foreignKey ?? '$pk',
      sourceKey: sourceKey ?? '${name}_id',
    );
  }
}

final class BreezeModelHasManyThroughRelation<M extends BreezeBaseModel> extends BreezeModelRelation<M> {
  // TODO: Rename to junction
  final String through;

  BreezeModelHasManyThroughRelation({
    required super.name,
    required this.through,

    /// self model key inside intermediate table
    /// '<source>_id'
    super.foreignKey,

    /// target model key inside intermediate table
    /// '<target>_id'
    super.sourceKey,
  });

  @override
  BreezeModelResolvedRelation<M> resolve<P extends BreezeBaseModel>(BreezeModelBlueprint<P> blueprint) {
    final table = blueprint.name;
    final pk = blueprint.key!;

    return BreezeModelResolvedHasManyThroughRelation(
      name: name,
      through: through,
      leftPk: pk,
      leftKey: foreignKey ?? '${table}_$pk', // TODO: singular table name
      rightKey: sourceKey ?? '${name}_id', // TODO: singular name
    );
  }

  /*
  BreezeModelHasManyThroughRelation({
    required super.name,
    required this.intermediateTable,

    /// self model key inside intermediate table
    String? foreignKey,

    /// target model key inside intermediate table
    String? sourceKey,
  }) : super(
         foreignKey: foreignKey ?? '<source>_id',
         sourceKey: sourceKey ?? '<target>_id',
       );
  */
}

// --- Resolved Relation Info

sealed class BreezeModelResolvedRelation<M extends BreezeBaseModel> {
  /// Column alias
  final String name;

  /// Foreign key
  final String foreignKey;

  /// Primary key
  final String sourceKey;

  Type get type => M;

  const BreezeModelResolvedRelation({
    required this.name,
    required this.foreignKey,
    required this.sourceKey,
  });
}

final class BreezeModelResolvedHasOneRelation<M extends BreezeBaseModel> extends BreezeModelResolvedRelation<M> {
  const BreezeModelResolvedHasOneRelation({
    required super.name,
    required super.foreignKey,
    required super.sourceKey,
  });
}

final class BreezeModelResolvedHasManyRelation<M extends BreezeBaseModel> extends BreezeModelResolvedRelation<M> {
  const BreezeModelResolvedHasManyRelation({
    required super.name,
    required super.foreignKey,
    required super.sourceKey,
  });
}

final class BreezeModelResolvedBelongsToRelation<M extends BreezeBaseModel> extends BreezeModelResolvedRelation<M> {
  const BreezeModelResolvedBelongsToRelation({
    required super.name,
    required super.foreignKey,
    required super.sourceKey,
  });
}

final class BreezeModelResolvedHasManyThroughRelation<M extends BreezeBaseModel>
    extends BreezeModelResolvedRelation<M> {
  final String leftPk;
  // TODO: rename to junction
  final String through;

  const BreezeModelResolvedHasManyThroughRelation({
    required super.name,
    required this.through,
    required this.leftPk,
    required String leftKey,
    required String rightKey,
  }) : super(foreignKey: leftKey, sourceKey: rightKey);
}
