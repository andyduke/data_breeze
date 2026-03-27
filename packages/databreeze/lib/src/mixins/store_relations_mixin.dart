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
        case BreezeModelResolvedHasOneRelation oneToOne:
          if (result.containsKey(oneToOne.name) && result[oneToOne.name] is BreezeModel) {
            // Remove from the result, since this value will be
            // processed later in updateRelationsAfterSave.
            result.remove(oneToOne.name);
          }
          break;

        case BreezeModelResolvedHasManyRelation oneToMany:
          if (result.containsKey(oneToMany.name) && result[oneToMany.name] is Iterable<BreezeModel>) {
            // Remove from the result, since this value will be
            // processed later in updateRelationsAfterSave.
            result.remove(oneToMany.name);
          }
          break;

        case BreezeModelResolvedBelongsToRelation manyToOne:
          if (result.containsKey(manyToOne.name) && result[manyToOne.name] is BreezeModel) {
            await updateManyToOneRelation(result[relation.name], result, manyToOne);
            result.remove(manyToOne.name);
          }
          break;

        case BreezeModelResolvedHasManyThroughRelation manyToMany:
          if (result.containsKey(manyToMany.name) && result[manyToMany.name] is Iterable<BreezeModel>) {
            // Remove from the result, since this value will be
            // processed later in updateRelationsAfterSave.
            result.remove(manyToMany.name);
          }
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
        case BreezeModelResolvedHasOneRelation oneToOne:
          if (record.containsKey(oneToOne.name) && record[oneToOne.name] is BreezeModel) {
            final BreezeModel item = record[oneToOne.name];
            await updateOneToOneRelation(item, relationInfo, record, blueprint);
          }
          break;

        case BreezeModelResolvedHasManyRelation oneToMany:
          if (record.containsKey(oneToMany.name) && record[oneToMany.name] is Iterable<BreezeModel>) {
            final Iterable<BreezeModel> items = record[oneToMany.name];
            await updateOneToManyRelation(items, relationInfo, record, blueprint);
          }
          break;

        case BreezeModelResolvedHasManyThroughRelation manyToMany:
          if (record.containsKey(manyToMany.name) && record[manyToMany.name] is Iterable<BreezeModel>) {
            final Iterable<BreezeModel> items = record[manyToMany.name];
            final relatedBlueprint = blueprintOf(relation.type);
            await updateManyToManyRelation(items, relationInfo, record, blueprint, relatedBlueprint);
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
  Future<void> updateManyToManyRelation(
    Iterable<BreezeModel> items,
    BreezeModelResolvedHasManyThroughRelation<BreezeBaseModel> relation,
    Map<String, dynamic> record,
    BreezeModelBlueprint blueprint,
    BreezeModelBlueprint relatedBlueprint,
  ) async {
    // Save related records
    final futures = [
      for (final item in items) save(item),
    ];
    final relatedItems = await Future.wait(futures);

    // Updating a junction collection with the keys of the main
    // collection and the saved related collections.
    //
    // Synchronizing a junction collection:

    // 1. Get a list of key pairs from the junction collection.
    final junctionItems = await fetchAllRecords(table: relation.through);

    // 2. Add new key pairs to it.
    final newJunctions = [
      for (final relatedItem in relatedItems)
        if (junctionItems.indexWhere((ji) => ji[relation.sourceKey] == relatedItem.id) == -1)
          {
            relation.foreignKey: record[blueprint.key],
            relation.sourceKey: relatedItem.id,
          },
    ];
    if (newJunctions.isNotEmpty) {
      await addRecords(name: relation.through, records: newJunctions);
    }

    // 3. Remove keys missing from the relatedItems collection.
    final obsoleteJunctions = [
      for (final junction in junctionItems)
        if (relatedItems.indexWhere((ri) => ri.id == junction[relation.sourceKey]) == -1) //
          junction[relation.sourceKey],
    ];
    if (obsoleteJunctions.isNotEmpty) {
      await deleteWhereRecords(
        name: relation.through,
        filter:
            BreezeField(relation.foreignKey).eq(record[blueprint.key]) &
            BreezeField(relation.sourceKey).inside(obsoleteJunctions),
      );
    }

    /* TODO: Cascade delete
    // 4. Remove records from the related collection whose keys are missing from junctionItems.
    if (obsoleteJunctions.isNotEmpty && relatedBlueprint.key != null) {
      await deleteWhereRecords(
        name: relatedBlueprint.name,
        filter: BreezeField(relatedBlueprint.key!).inside(obsoleteJunctions),
      );
    }
    */
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
