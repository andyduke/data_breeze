import 'package:collection/collection.dart';
import 'package:databreeze/src/migration/migration_manager.dart';
import 'package:databreeze/src/mixins/store_relations_mixin.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/model_column.dart';
import 'package:databreeze/src/model_schema.dart';
import 'package:databreeze/src/relations/model_relation.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/type_converters.dart';
import 'package:meta/meta.dart';

abstract class BreezeMigrationStrategy<D> {
  const BreezeMigrationStrategy();

  Future<void> migrate(BreezeStore store, [D? extra]);
}

abstract class BreezeSchemaMigrationStrategy<D> extends BreezeMigrationStrategy<D> {
  final bool Function(BreezeBaseModelSchema schema)? filter;
  final BreezeMigrationCallback<D>? onBeforeMigration;
  final BreezeMigrationCallback<D>? onAfterMigration;
  final BreezeMigrationBeforeVersionCallback<D>? onBeforeVersion;
  final BreezeMigrationAfterVersionCallback<D>? onAfterVersion;

  const BreezeSchemaMigrationStrategy({
    this.filter,
    this.onBeforeMigration,
    this.onAfterMigration,
    this.onBeforeVersion,
    this.onAfterVersion,
  });

  @override
  Future<void> migrate(BreezeStore store, [D? db]) async {
    // Filter only models with a primary key (ignore view models).
    Iterable<BreezeModelBlueprint<BreezeModel>> schemes = store.blueprints.values
        .whereType<BreezeModelBlueprint<BreezeModel>>();

    if (filter != null) {
      schemes = schemes.where((blueprint) => filter!(blueprint));
    }

    if (store is BreezeStoreRelations) {
      expandRelationshipKeys(store, schemes);
    }

    await migrateSchemas(schemes, db, store.typeConverters);
  }

  // @protected
  Future<void> migrateSchemas(
    Iterable<BreezeBaseModelSchema> schemas, [
    D? db,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  ]);

  @protected
  void expandRelationshipKeys(BreezeStoreRelations store, Iterable<BreezeModelBlueprint<BreezeModel>> schemes) {
    // [ModelType] = <BreezeModelColumn>[]
    final Map<Type, List<BreezeModelColumn>> relationshipKeys = {};

    for (final schema in schemes) {
      // Skip versioned schema - relationship keys are added only
      // for unversioned schemas; for versioned schemas, keys
      // must be specified manually.
      if (schema.versions.length > 1) continue;

      for (final relation in schema.relations) {
        final relationInfo = store.resolveRelation(relation, schema);
        switch (relationInfo) {
          case BreezeModelResolvedHasOneRelation oneToOne:
            relationshipKeys[oneToOne.type] = [
              BreezeModelColumnTyped(
                oneToOne.foreignKey.name,
                type: oneToOne.foreignKey.type,
                isNullable: true, // TODO: ???
              ),
            ];
            break;

          case BreezeModelResolvedHasManyRelation oneToMany:
            relationshipKeys[oneToMany.type] = [
              BreezeModelColumnTyped(
                oneToMany.foreignKey.name,
                type: oneToMany.foreignKey.type,
                isNullable: true, // TODO: ???
              ),
            ];
            break;

          case BreezeModelResolvedBelongsToRelation manyToOne:
            relationshipKeys[manyToOne.type] = [
              BreezeModelColumnTyped(
                manyToOne.sourceKey.name,
                type: manyToOne.sourceKey.type,
                isNullable: true, // TODO: ???
              ),
            ];
            break;

          case BreezeModelResolvedHasManyThroughRelation manyToMany:
            // Skip because all keys are in the junction schema.
            break;
        }
      }
    }

    for (final MapEntry(key: model, value: columns) in relationshipKeys.entries) {
      final schema = schemes.firstWhereOrNull((s) => s.type == model);
      if (schema != null) {
        for (final column in columns) {
          // Add a relationship key if it has not been added to the schema manually.
          if (!schema.columns.containsKey(column.name)) {
            schema.columns[column.name] = column;
          }
        }
      }
    }
  }
}
