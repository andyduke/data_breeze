import 'package:databreeze/src/filter.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/relations/model_relation.dart';
import 'package:databreeze/src/relations/store_relations.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:meta/meta.dart';

mixin BreezeStoreRelations on BreezeStore {
  @override
  Future<BreezeFetchRelationsRequest> preFetchRelations(Set<BreezeModelRelation> relations) async {
    final request = BreezeFetchRelationsRequest(relations: relations);
    return request;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRelations<M extends BreezeBaseModel>(
    BreezeModelBlueprint<M> blueprint,
    BreezeFetchRelationsRequest request,
    List<Map<String, dynamic>> records,
  ) async {
    /*
    final List<Map<String, dynamic>> result = [
      for (final record in records) {...record},
    ];
    */
    final result = records;

    for (final relation in request.relations) {
      final relationInfo = relation.resolve(blueprint);
      final relationBlueprint = blueprintOf(relation.type);

      switch (relationInfo) {
        case BreezeModelResolvedHasOneRelation hasOne:
          await fetchHasOne(hasOne, result, relationBlueprint);
          break;

        case BreezeModelResolvedHasManyRelation hasMany:
          await fetchHasMany(hasMany, result, relationBlueprint);
          break;

        case BreezeModelResolvedBelongsToRelation belongsTo:
          await fetchBelongsTo(belongsTo, result, relationBlueprint);
          break;

        case BreezeModelResolvedHasManyThroughRelation hasManyThrough:
          await fetchHasManyThrough(hasManyThrough, result, relationBlueprint);
          break;
      }
    }

    return result;
  }

  @override
  Future<void> fetchHasOne(
    BreezeModelResolvedHasOneRelation relation,
    List<Map<String, dynamic>> records,
    BreezeModelBlueprint relationBlueprint,
  ) async {
    final ids = {
      for (final record in records)
        if (record.containsKey(relation.sourceKey)) record[relation.sourceKey],
    }.toList(growable: false);

    final rows = await fetchAllRecords(
      table: relationBlueprint.name,
      request: BreezeFetchRequest(
        filter: BreezeField(relation.foreignKey).inside(ids),
        // sortBy: sortBy,
      ),
      blueprint: relationBlueprint,
    );
    final relatedRows = Map<dynamic, Map<String, dynamic>>.fromIterable(
      rows,
      key: (row) => row.id,
    );

    for (final record in records) {
      if (record.containsKey(relation.sourceKey)) {
        record[relation.name] = relatedRows[record[relation.sourceKey]];
      }
    }
  }

  @override
  Future<void> fetchHasMany(
    BreezeModelResolvedHasManyRelation relation,
    List<Map<String, dynamic>> records,
    BreezeModelBlueprint relationBlueprint,
  ) async {
    final ids = {
      for (final record in records)
        if (record.containsKey(relation.sourceKey)) record[relation.sourceKey],
    }.toList(growable: false);

    final rows = await fetchAllRecords(
      table: relationBlueprint.name,
      request: BreezeFetchRequest(
        filter: BreezeField(relation.foreignKey).inside(ids),
        // sortBy: sortBy,
      ),
      blueprint: relationBlueprint,
    );
    final relatedRows = <dynamic, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      (relatedRows[row[relation.foreignKey]] ??= []).add(row);
    }

    for (final record in records) {
      if (record.containsKey(relation.sourceKey)) {
        record[relation.name] = relatedRows[record[relation.sourceKey]];
      }
    }
  }

  @override
  Future<void> fetchBelongsTo(
    BreezeModelResolvedBelongsToRelation relation,
    List<Map<String, dynamic>> records,
    BreezeModelBlueprint relationBlueprint,
  ) async {
    final ids = {
      for (final record in records)
        if (record.containsKey(relation.sourceKey)) record[relation.sourceKey],
    }.toList(growable: false);

    final rows = await fetchAllRecords(
      table: relationBlueprint.name,
      request: BreezeFetchRequest(
        filter: BreezeField(relation.foreignKey).inside(ids),
        // sortBy: sortBy,
      ),
      blueprint: relationBlueprint,
    );
    final relatedRows = Map<dynamic, Map<String, dynamic>>.fromIterable(
      rows,
      key: (row) => row[relationBlueprint.key],
    );

    for (final record in records) {
      if (record.containsKey(relation.sourceKey)) {
        record[relation.name] = relatedRows[record[relation.sourceKey]];
      }
    }
  }

  @override
  Future<void> fetchHasManyThrough(
    BreezeModelResolvedHasManyThroughRelation relation,
    List<Map<String, dynamic>> records,
    BreezeModelBlueprint relationBlueprint,
  ) async {
    // Do nothing
  }

  @override
  Future<void> updateRelationsBeforeSave<M extends BreezeBaseModel>(
    BreezeModelBlueprint<M> blueprint,
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  ) async {
    for (final relation in relations) {
      final relationInfo = relation.resolve(blueprint);

      switch (relationInfo) {
        case BreezeModelResolvedHasOneRelation hasOne:
          if (record.containsKey(hasOne.name) && record[hasOne.name] is BreezeModel) {
            final savedItem = await save(record[hasOne.name]);
            record.remove(hasOne.name);
            record[relationInfo.foreignKey] = savedItem.id;
          }
          break;

        case BreezeModelResolvedHasManyRelation hasMany:
          if (record.containsKey(hasMany.name) && record[hasMany.name] is Iterable<BreezeModel>) {
            final relItems = record[hasMany.name];
            record.remove(hasMany.name);

            final relKeys = [];
            for (final relItem in relItems) {
              final savedItem = await save(relItem);
              relKeys.add(savedItem.id);
            }

            record[relationInfo.foreignKey] = relKeys;
          }
          break;

        case BreezeModelResolvedBelongsToRelation belongsTo:
          if (record.containsKey(belongsTo.name) && record[belongsTo.name] is BreezeModel) {
            await save(record[belongsTo.name]);
            record.remove(belongsTo.name);
          }
          break;

        case BreezeModelResolvedHasManyThroughRelation hasManyThrough:
          await updateHasManyThroughRelationBeforeSave(hasManyThrough, record);
          break;
      }
    }
  }

  @protected
  Future<void> updateHasManyThroughRelationBeforeSave<M extends BreezeBaseModel>(
    BreezeModelResolvedHasManyThroughRelation relation,
    Map<String, dynamic> record,
  ) async {
    // Do nothing
  }

  @override
  Future<void> updateRelationsAfterSave<M extends BreezeBaseModel>(
    M record,
    Set<BreezeModelRelation> relations,
  ) async {}

  @override
  Future<void> deleteRelationsBeforeDelete(
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  ) async {
    // TODO: Implement this
  }

  @override
  Future<void> deleteRelationsAfterDelete(
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  ) async {
    // TODO: Implement this
  }
}
