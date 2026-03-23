import 'package:databreeze/src/filter.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/relations/model_relation.dart';
import 'package:databreeze/src/relations/store_relations.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:meta/meta.dart';

mixin BreezeStoreRelations on BreezeStore {
  @protected
  BreezeModelResolvedRelation resolveRelation(
    BreezeModelRelation relation,
    BreezeModelBlueprint blueprint,
  ) {
    final table = blueprint.name;
    final pk = blueprint.key;

    final BreezeModelResolvedRelation resolved = switch (relation) {
      BreezeModelHasOneRelation oneToOne => BreezeModelResolvedHasOneRelation(
        name: oneToOne.name,
        foreignKey: oneToOne.foreignKey ?? '${table}_$pk',
        sourceKey: oneToOne.sourceKey ?? 'id',
      ),
      BreezeModelHasManyRelation oneToMany => BreezeModelResolvedHasManyRelation(
        name: oneToMany.name,
        foreignKey: oneToMany.foreignKey ?? '${table}_$pk',
        sourceKey: oneToMany.sourceKey ?? 'id',
      ),
      BreezeModelBelongsToRelation manyToOne => BreezeModelResolvedBelongsToRelation(
        name: manyToOne.name,
        foreignKey: manyToOne.foreignKey ?? '$pk',
        sourceKey: manyToOne.sourceKey ?? '${manyToOne.name}_id',
      ),
      BreezeModelHasManyThroughRelation manyToMany => BreezeModelResolvedHasManyThroughRelation(
        name: manyToMany.name,
        through: manyToMany.through,
        leftPk: pk!,
        leftKey: manyToMany.foreignKey ?? '${table}_$pk', // TODO: singular table name
        rightKey: manyToMany.sourceKey ?? '${manyToMany.name}_id', // TODO: singular name
      ),
    };
    return resolved;
  }

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
      // final relationInfo = relation.resolve(blueprint);
      final relationInfo = resolveRelation(relation, blueprint);
      final relationBlueprint = blueprintOf(relation.type);

      switch (relationInfo) {
        case BreezeModelResolvedHasOneRelation hasOne:
          await fetchOneToOne(hasOne, result, relationBlueprint);
          break;

        case BreezeModelResolvedHasManyRelation hasMany:
          await fetchOneToMany(hasMany, result, relationBlueprint);
          break;

        case BreezeModelResolvedBelongsToRelation belongsTo:
          await fetchManyToOne(belongsTo, result, relationBlueprint);
          break;

        case BreezeModelResolvedHasManyThroughRelation hasManyThrough:
          await fetchManyToMany(hasManyThrough, result, relationBlueprint);
          break;
      }
    }

    return result;
  }

  @protected
  Future<void> fetchOneToOne(
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
      key: (row) => row[relation.sourceKey],
    );

    for (final record in records) {
      if (record.containsKey(relation.sourceKey)) {
        record[relation.name] = relatedRows[record[relation.sourceKey]];
      }
    }
  }

  @protected
  Future<void> fetchOneToMany(
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

  @protected
  Future<void> fetchManyToOne(
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

  @protected
  Future<void> fetchManyToMany(
    BreezeModelResolvedHasManyThroughRelation relation,
    List<Map<String, dynamic>> records,
    BreezeModelBlueprint relationBlueprint,
  ) async {
    // Default implementation.
    // SQL stores and others may have their own, more optimal implementation.

    final leftPk = relation.leftPk;
    final rightPk = relationBlueprint.key!;

    // Collect key values ​​from main records
    final ids = {
      for (final record in records)
        if (record.containsKey(leftPk)) record[leftPk],
    }.toList(growable: false);

    // Get the junction list of the main model and the child model
    final junctionRows = await fetchAllRecords(
      table: relation.through,
      request: BreezeFetchRequest(
        filter: BreezeField(relation.foreignKey).inside(ids),
        // sortBy: sortBy,
      ),
    );
    final junctionIds = junctionRows.map((row) => row[relation.sourceKey]).toSet();

    // Get a list of child model records for all main models
    final rowsList = await fetchAllRecords(
      table: relationBlueprint.name,
      request: BreezeFetchRequest(
        filter: BreezeField(rightPk).inside(junctionIds),
        // sortBy: sortBy,
      ),
      blueprint: relationBlueprint,
    );
    final rows = Map<dynamic, Map<String, dynamic>>.fromIterable(
      rowsList,
      key: (row) => row[rightPk],
    );

    // Collect lists of child model keys for the corresponding master models:
    // { main_id: [ child_id, child_id ] }
    final relatedIds = <dynamic, List<dynamic>>{};
    for (final junctionRow in junctionRows) {
      (relatedIds[junctionRow[relation.foreignKey]] ??= []).add(junctionRow[relation.sourceKey]);
    }

    // Collect lists of child model records for the corresponding master models
    // { main_id: [ child_record, child_record ] }
    final relatedRows = <dynamic, List<Map<String, dynamic>>>{};
    for (final MapEntry(key: leftId, value: rightIds) in relatedIds.entries) {
      relatedRows[leftId] = rightIds
          .map((id) => rows[id]) //
          .where((row) => (row != null))
          .cast<Map<String, dynamic>>()
          .toList(growable: false);
    }

    for (final record in records) {
      if (record.containsKey(leftPk)) {
        record[relation.name] = relatedRows[record[leftPk]];
      }
    }
  }

  @override
  Future<Map<String, dynamic>> updateRelationsBeforeSave<M extends BreezeBaseModel>(
    BreezeModelBlueprint<M> blueprint,
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  ) async {
    final result = {...record};

    for (final relation in relations) {
      // final relationInfo = relation.resolve(blueprint);
      final relationInfo = resolveRelation(relation, blueprint);

      switch (relationInfo) {
        case BreezeModelResolvedHasOneRelation hasOne:
          if (result.containsKey(hasOne.name) && result[hasOne.name] is BreezeModel) {
            // Remove from the result, since this value will be
            // processed later in updateRelationsAfterSave.
            result.remove(hasOne.name);
          }
          break;

        case BreezeModelResolvedHasManyRelation hasMany:
          if (result.containsKey(hasMany.name) && result[hasMany.name] is Iterable<BreezeModel>) {
            // Remove from the result, since this value will be
            // processed later in updateRelationsAfterSave.
            result.remove(hasMany.name);
          }
          break;

        case BreezeModelResolvedBelongsToRelation belongsTo:
          if (result.containsKey(belongsTo.name) && result[belongsTo.name] is BreezeModel) {
            await updateManyToOneRelation(record[relation.name], result, belongsTo);
            result.remove(belongsTo.name);
          }
          break;

        case BreezeModelResolvedHasManyThroughRelation hasManyThrough:
          await updateManyToManyRelation(hasManyThrough, result);
          break;
      }
    }

    return result;
  }

  @override
  Future<void> updateRelationsAfterSave<M extends BreezeBaseModel>(
    BreezeModelBlueprint<M> blueprint,
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  ) async {
    for (final relation in relations) {
      // final relationInfo = relation.resolve(blueprint);
      final relationInfo = resolveRelation(relation, blueprint);

      switch (relationInfo) {
        case BreezeModelResolvedHasOneRelation hasOne:
          if (record.containsKey(hasOne.name) && record[hasOne.name] is BreezeModel) {
            final BreezeModel item = record[hasOne.name];
            await updateOneToOneRelation(item, relationInfo, record, blueprint);
          }
          break;

        case BreezeModelResolvedHasManyRelation hasMany:
          if (record.containsKey(hasMany.name) && record[hasMany.name] is Iterable<BreezeModel>) {
            final Iterable<BreezeModel> items = record[hasMany.name];
            await updateOneToManyRelation(items, relationInfo, record, blueprint);
          }
          break;

        default:
        // Do nothing
      }
    }
  }

  @protected
  Future<void> updateOneToOneRelation(
    BreezeModel item,
    BreezeModelResolvedHasOneRelation relation,
    Map<String, dynamic> record,
    BreezeModelBlueprint blueprint,
  ) async {
    await saveWithOptions(
      item,
      extraData: {
        relation.foreignKey: record[blueprint.key],
      },
    );
  }

  @protected
  Future<void> updateOneToManyRelation(
    Iterable<BreezeModel> items,
    BreezeModelResolvedHasManyRelation<BreezeBaseModel> relation,
    Map<String, dynamic> record,
    BreezeModelBlueprint blueprint,
  ) async {
    final futures = [
      for (final item in items)
        saveWithOptions(
          item,
          extraData: {
            relation.foreignKey: record[blueprint.key],
          },
        ),
    ];
    await Future.wait(futures);
  }

  @protected
  Future<void> updateManyToOneRelation(
    BreezeModel item,
    Map<String, dynamic> record,
    BreezeModelResolvedBelongsToRelation<BreezeBaseModel> relation,
  ) async {
    final relatedItem = await save(item);
    record[relation.sourceKey] = relatedItem.id;
  }

  @protected
  Future<void> updateManyToManyRelation<M extends BreezeBaseModel>(
    BreezeModelResolvedHasManyThroughRelation relation,
    Map<String, dynamic> record,
  ) async {
    // TODO: Implement this
  }

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
