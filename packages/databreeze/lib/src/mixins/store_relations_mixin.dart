import 'package:databreeze/src/filter.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/relations/model_relation.dart';
import 'package:databreeze/src/relations/store_relations.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:meta/meta.dart';

mixin BreezeStoreRelations on BreezeStore {
  @internal
  BreezeModelResolvedRelation resolveRelation(
    BreezeModelRelation relation,
    BreezeModelBlueprint blueprint,
  ) {
    final table = blueprint.name;
    final pk = blueprint.key;

    final BreezeModelResolvedRelation resolved = switch (relation) {
      BreezeModelHasOneRelation oneToOne => BreezeModelResolvedHasOneRelation(
        type: oneToOne.type,
        name: oneToOne.name,
        foreignKey: BreezeRelationTypedKey(
          oneToOne.foreignKey?.name ?? '${table}_$pk', // TODO: singular ${table}
          oneToOne.foreignKey?.type ?? int,
        ),
        sourceKey: BreezeRelationTypedKey(
          oneToOne.sourceKey?.name ?? 'id',
          oneToOne.sourceKey?.type ?? int,
        ),
        deleteRule: relation.deleteRule,
      ),
      BreezeModelHasManyRelation oneToMany => BreezeModelResolvedHasManyRelation(
        type: oneToMany.type,
        name: oneToMany.name,
        foreignKey: BreezeRelationTypedKey(
          oneToMany.foreignKey?.name ?? '${table}_$pk', // TODO: singular ${table}
          oneToMany.foreignKey?.type ?? int,
        ),
        sourceKey: BreezeRelationTypedKey(
          oneToMany.sourceKey?.name ?? 'id',
          oneToMany.sourceKey?.type ?? int,
        ),
        deleteRule: relation.deleteRule,
      ),
      BreezeModelBelongsToRelation manyToOne => BreezeModelResolvedBelongsToRelation(
        type: manyToOne.type,
        name: manyToOne.name,
        foreignKey: BreezeRelationTypedKey(
          manyToOne.foreignKey?.name ?? '$pk',
          manyToOne.foreignKey?.type ?? int,
        ),
        sourceKey: BreezeRelationTypedKey(
          manyToOne.sourceKey?.name ?? '${manyToOne.name}_id', // TODO: singular ${manyToOne.name}
          manyToOne.sourceKey?.type ?? int,
        ),
        deleteRule: relation.deleteRule,
      ),
      BreezeModelHasManyThroughRelation manyToMany => BreezeModelResolvedHasManyThroughRelation(
        type: manyToMany.type,
        name: manyToMany.name,
        junction: blueprintOf(manyToMany.junction),
        leftPk: pk!,
        leftKey: BreezeRelationTypedKey(
          manyToMany.foreignKey?.name ?? '${table}_$pk', // TODO: singular ${table}
          manyToMany.foreignKey?.type ?? int,
        ),
        rightKey: BreezeRelationTypedKey(
          manyToMany.sourceKey?.name ?? '${manyToMany.name}_id', // TODO: singular ${manyToMany.name}
          manyToMany.sourceKey?.type ?? int,
        ),
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
        if (record.containsKey(relation.sourceKey.name)) record[relation.sourceKey.name],
    }.toList(growable: false);

    final rows = await fetchAllRecords(
      table: relationBlueprint.name,
      request: BreezeFetchRequest(
        filter: BreezeField(relation.foreignKey.name).inside(ids),
        // sortBy: sortBy,
      ),
      blueprint: relationBlueprint,
    );
    final relatedRows = Map<dynamic, Map<String, dynamic>>.fromIterable(
      rows,
      key: (row) => row[relation.sourceKey.name],
    );

    for (final record in records) {
      if (record.containsKey(relation.sourceKey.name)) {
        record[relation.name] = relatedRows[record[relation.sourceKey.name]];
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
        if (record.containsKey(relation.sourceKey.name)) record[relation.sourceKey.name],
    }.toList(growable: false);

    final rows = await fetchAllRecords(
      table: relationBlueprint.name,
      request: BreezeFetchRequest(
        filter: BreezeField(relation.foreignKey.name).inside(ids),
        // sortBy: sortBy,
      ),
      blueprint: relationBlueprint,
    );
    final relatedRows = <dynamic, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      (relatedRows[row[relation.foreignKey.name]] ??= []).add(row);
    }

    for (final record in records) {
      if (record.containsKey(relation.sourceKey.name)) {
        record[relation.name] = relatedRows[record[relation.sourceKey.name]];
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
        if (record.containsKey(relation.sourceKey.name)) record[relation.sourceKey.name],
    }.toList(growable: false);

    final rows = await fetchAllRecords(
      table: relationBlueprint.name,
      request: BreezeFetchRequest(
        filter: BreezeField(relation.foreignKey.name).inside(ids),
        // sortBy: sortBy,
      ),
      blueprint: relationBlueprint,
    );
    final relatedRows = Map<dynamic, Map<String, dynamic>>.fromIterable(
      rows,
      key: (row) => row[relationBlueprint.key],
    );

    for (final record in records) {
      if (record.containsKey(relation.sourceKey.name)) {
        record[relation.name] = relatedRows[record[relation.sourceKey.name]];
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
      table: relation.junction.name,
      request: BreezeFetchRequest(
        filter: BreezeField(relation.foreignKey.name).inside(ids),
        // sortBy: sortBy,
      ),
    );
    final junctionIds = junctionRows.map((row) => row[relation.sourceKey.name]).toSet();

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
      (relatedIds[junctionRow[relation.foreignKey.name]] ??= []).add(junctionRow[relation.sourceKey.name]);
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
          if (result.containsKey(oneToOne.name) && result[oneToOne.name] is BreezeModel?) {
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
          if (result.containsKey(manyToOne.name) && result[manyToOne.name] is BreezeModel?) {
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
          if (record.containsKey(oneToOne.name) && record[oneToOne.name] is BreezeModel?) {
            final BreezeModel? item = record[oneToOne.name];
            if (item != null) {
              await updateOneToOneRelation(item, oneToOne, record);
            } else {
              // If null is assigned to a relationship, the foreign key in
              // the related record must be reset.

              final relatedBlueprint = blueprintOf(oneToOne.type);
              switch (oneToOne.deleteRule) {
                case BreezeRelationshipDeleteRule.nullify:
                  await nullifyOneToOneRelation(
                    oneToOne,
                    record,
                    relatedBlueprint,
                  );
                  break;

                case BreezeRelationshipDeleteRule.cascade:
                  await deleteOneToOneRelation(
                    oneToOne,
                    record[oneToOne.sourceKey.name],
                    relatedBlueprint,
                  );
                  break;
              }
            }
          }
          break;

        case BreezeModelResolvedHasManyRelation oneToMany:
          if (record.containsKey(oneToMany.name) && record[oneToMany.name] is Iterable<BreezeModel>) {
            final Iterable<BreezeModel> items = record[oneToMany.name];
            await updateOneToManyRelation(items, relationInfo, record);
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
  ) async {
    await saveWithOptions(
      item,
      extraData: {
        relation.foreignKey.name: record[relation.sourceKey.name],
      },
    );
  }

  @protected
  Future<void> updateOneToManyRelation(
    Iterable<BreezeModel> items,
    BreezeModelResolvedHasManyRelation relation,
    Map<String, dynamic> record,
  ) async {
    final futures = [
      for (final item in items)
        saveWithOptions(
          item,
          extraData: {
            relation.foreignKey.name: record[relation.sourceKey.name],
          },
        ),
    ];
    await Future.wait(futures);
  }

  @protected
  Future<void> updateManyToOneRelation(
    BreezeModel? item,
    Map<String, dynamic> record,
    BreezeModelResolvedBelongsToRelation relation,
  ) async {
    if (item != null) {
      final relatedItem = await save(item);
      record[relation.sourceKey.name] = relatedItem.id;
    } else {
      record[relation.sourceKey.name] = null;
    }
  }

  @protected
  Future<void> updateManyToManyRelation(
    Iterable<BreezeModel> items,
    BreezeModelResolvedHasManyThroughRelation relation,
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
    final junctionItems = await fetchAllRecords(table: relation.junction.name);

    // 2. Add new key pairs to it.
    final newJunctions = [
      for (final relatedItem in relatedItems)
        if (junctionItems.indexWhere((ji) => ji[relation.sourceKey.name] == relatedItem.id) == -1)
          {
            relation.foreignKey.name: record[blueprint.key],
            relation.sourceKey.name: relatedItem.id,
          },
    ];
    if (newJunctions.isNotEmpty) {
      await addRecords(name: relation.junction.name, records: newJunctions);
    }

    // 3. Remove keys missing from the relatedItems collection.
    final obsoleteJunctions = [
      for (final junction in junctionItems)
        if (relatedItems.indexWhere((ri) => ri.id == junction[relation.sourceKey.name]) == -1) //
          junction[relation.sourceKey.name],
    ];
    if (obsoleteJunctions.isNotEmpty) {
      await deleteWhereRecords(
        name: relation.junction.name,
        filter:
            BreezeField(relation.foreignKey.name).eq(record[blueprint.key]) &
            BreezeField(relation.sourceKey.name).inside(obsoleteJunctions),
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
  Future<void> deleteRelationsBeforeDelete<M extends BreezeBaseModel>(
    BreezeModelBlueprint<M> blueprint,
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  ) async {
    // final result = {...record};

    /*
    for (final relation in relations) {
      final relationInfo = resolveRelation(relation, blueprint);

      switch (relationInfo) {
        case BreezeModelResolvedHasOneRelation oneToOne:
          if (result.containsKey(oneToOne.name) && result[oneToOne.name] is BreezeModel?) {
            // Remove from the result, since this value will be
            // processed later in deleteRelationsAfterDelete.
            result.remove(oneToOne.name);
          }
          break;

        case BreezeModelResolvedHasManyRelation oneToMany:
          if (result.containsKey(oneToMany.name) && result[oneToMany.name] is Iterable<BreezeModel>) {
            // Remove from the result, since this value will be
            // processed later in deleteRelationsAfterDelete.
            result.remove(oneToMany.name);
          }
          break;

        case BreezeModelResolvedBelongsToRelation manyToOne:
          if (result.containsKey(manyToOne.name) && result[manyToOne.name] is BreezeModel?) {
            // Remove from the result, since this value will be
            // processed later in deleteRelationsAfterDelete.
            result.remove(manyToOne.name);
          }
          break;

        case BreezeModelResolvedHasManyThroughRelation manyToMany:
          if (result.containsKey(manyToMany.name) && result[manyToMany.name] is Iterable<BreezeModel>) {
            // Remove from the result, since this value will be
            // processed later in deleteRelationsAfterDelete.
            result.remove(manyToMany.name);
          }
          break;
      }
    }
    */

    // return result;
  }

  @override
  Future<void> deleteRelationsAfterDelete<M extends BreezeBaseModel>(
    BreezeModelBlueprint<M> blueprint,
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  ) async {
    for (final relation in relations) {
      final relationInfo = resolveRelation(relation, blueprint);

      switch (relationInfo) {
        case BreezeModelResolvedHasOneRelation oneToOne:
          final relatedBlueprint = blueprintOf(oneToOne.type);
          switch (oneToOne.deleteRule) {
            case BreezeRelationshipDeleteRule.nullify:
              await nullifyOneToOneRelation(
                oneToOne,
                record,
                relatedBlueprint,
              );
              break;

            case BreezeRelationshipDeleteRule.cascade:
              await deleteOneToOneRelation(
                oneToOne,
                record[oneToOne.sourceKey.name],
                relatedBlueprint,
              );
              break;
          }
          break;

        case BreezeModelResolvedHasManyRelation oneToMany:
          final relatedBlueprint = blueprintOf(oneToMany.type);
          switch (oneToMany.deleteRule) {
            case BreezeRelationshipDeleteRule.nullify:
              await nullifyOneToManyRelation(
                oneToMany,
                record[oneToMany.sourceKey.name],
                relatedBlueprint,
              );
              break;

            case BreezeRelationshipDeleteRule.cascade:
              await deleteOneToManyRelation(
                oneToMany,
                record[oneToMany.sourceKey.name],
                relatedBlueprint,
              );
              break;
          }
          break;

        case BreezeModelResolvedHasManyThroughRelation manyToMany:
          final relatedBlueprint = blueprintOf(relation.type);
          final recordId = record[blueprint.key];
          await deleteManyToManyRelation(manyToMany, recordId, relatedBlueprint);
          break;

        default:
        // Do nothing
      }
    }
  }

  @protected
  Future<void> nullifyOneToOneRelation(
    BreezeModelResolvedHasOneRelation relation,
    Map<String, dynamic> record,
    BreezeModelBlueprint relatedBlueprint,
  ) async {
    await updateRecord(
      name: relatedBlueprint.name,
      key: relation.foreignKey.name,
      keyValue: record[relation.sourceKey.name],
      record: {
        relation.foreignKey.name: null,
      },
    );
  }

  @protected
  Future<void> deleteOneToOneRelation(
    BreezeModelResolvedHasOneRelation relation,
    dynamic keyValue,
    BreezeModelBlueprint relatedBlueprint,
  ) async {
    await deleteRecord(
      name: relatedBlueprint.name,
      key: relation.foreignKey.name,
      keyValue: keyValue,
    );
  }

  @protected
  Future<void> nullifyOneToManyRelation(
    BreezeModelResolvedHasManyRelation relation,
    dynamic keyValue,
    BreezeModelBlueprint relatedBlueprint,
  ) async {
    await bulkUpdateRecords(
      name: relatedBlueprint.name,
      key: relation.foreignKey.name,
      keyValues: [keyValue],
      data: {
        relation.foreignKey.name: null,
      },
    );
  }

  @protected
  Future<void> deleteOneToManyRelation(
    BreezeModelResolvedHasManyRelation relation,
    dynamic keyValue,
    BreezeModelBlueprint relatedBlueprint,
  ) async {
    await deleteWhereRecords(
      name: relatedBlueprint.name,
      filter: BreezeField(relation.foreignKey.name).eq(keyValue),
    );
  }

  @protected
  Future<void> deleteManyToManyRelation(
    BreezeModelResolvedHasManyThroughRelation relation,
    dynamic keyValue,
    BreezeModelBlueprint relatedBlueprint,
  ) async {
    await deleteWhereRecords(
      name: relation.junction.name,
      filter: BreezeField(relation.foreignKey.name).eq(keyValue),
    );
  }
}
