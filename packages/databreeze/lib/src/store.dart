import 'dart:async';
import 'package:databreeze/src/filter.dart';
import 'package:databreeze/src/migration/migration_strategy.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/relations/model_relation.dart';
import 'package:databreeze/src/relations/store_relations.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:databreeze/src/store_change.dart';
import 'package:databreeze/src/type_converters.dart';
import 'package:databreeze/src/types.dart';
import 'package:meta/meta.dart';

enum BreezeAggregationOp { count, sum, avg, min, max }

typedef BreezeStoreErrorCallback = void Function(Object error, StackTrace? stackTrace);

/// {@template breeze.store.description}
///
/// An interface class that provides the ability to
/// store data represented by models.
///
/// This class is a base class and does not directly
/// implement data storage.
///
/// > *For storing data in **SQLite**, you can use the store*
/// > *implementation provided by the [BreezeSqliteStore] class.*
///
/// This class can be used to implement data storage in
/// remote databases such as MySQL, Postgres, and Mongo,
/// as well as for accessing data through various
/// external APIs.
///
/// {@endtemplate}
abstract class BreezeStore with BreezeStorageTypeConverters {
  /// "Blueprints" of models that this store can work with.
  final Map<Type, BreezeModelBlueprint> blueprints;

  /// {@template breeze.store.migrationStrategy}
  /// Strategy for migrating the structure and data of
  /// this store when the structure of the models changes.
  /// {@endtemplate}
  final BreezeMigrationStrategy? migrationStrategy;

  /// {@template breeze.store.onError}
  /// Called when an error occurs in the store.
  /// {@endtemplate}
  ///
  /// For example, for an SQL database, when an
  /// error occurs executing an SQL query.
  final BreezeStoreErrorCallback? onError;

  /// Data type converters supported by this store.
  ///
  /// They are used to convert Dart data types,
  /// as well as complex data types represented by
  /// objects in your application, into data types
  /// that can be stored by the underlying
  /// backend (such as a database).
  ///
  /// This property contains all supported store
  /// type converters, including converters from
  /// [defaultTypeConverters] and those passed
  /// in the store constructor.
  @override
  late final Set<BreezeBaseTypeConverter> typeConverters;

  /// Default data type converters.
  ///
  /// In a store implementation, this property must
  /// be overridden to add support for data types
  /// specific to that store implementation.
  ///
  /// For example, for SQLite, this property returns
  /// converters for the DateTime type.
  Set<BreezeBaseTypeConverter> get defaultTypeConverters => {};

  /// {@macro breeze.store.description}
  ///
  /// * [models] - A list of model "blueprints" that this store can work with.
  /// * [migrationStrategy] -
  ///   {@macro breeze.store.migrationStrategy}
  /// * [typeConverters] - Type converters that are supported by this store.
  /// * [onError] -
  ///   {@macro breeze.store.onError}
  BreezeStore({
    Set<BreezeModelBlueprint> models = const {},
    this.migrationStrategy,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
    this.onError,
  }) : blueprints = Map.fromIterable(models, key: (b) => b.type) {
    // TODO: Loop through all relationships of models from "blueprints" and
    //  add blueprints of related models to "blueprints" if they are not there yet.
    this.typeConverters = {...typeConverters, ...defaultTypeConverters};
  }

  void dispose() {}

  /// A stream of [BreezeStoreChange] with all the changes
  /// that occur in the database
  Stream<BreezeStoreChange> get changes => _changesController.stream;

  final StreamController<BreezeStoreChange> _changesController = StreamController<BreezeStoreChange>.broadcast();

  @protected
  void notify(BreezeStoreChange event) {
    _changesController.sink.add(event);
  }

  BreezeModelBlueprint blueprintOf(Type modelType) {
    final blueprint = blueprints[modelType];
    if (blueprint == null) {
      throw BreezeBlueprintNotFoundException(modelType);
    }
    return blueprint;
  }

  // --- Fetching API

  Future<M?> fetchWithRequest<M extends BreezeBaseModel>(
    BreezeAbstractFetchRequest request, {
    BreezeModelBlueprint<M>? blueprint,
  }) async {
    final modelBlueprint = blueprint ?? (blueprintOf(M) as BreezeModelBlueprint<M>);

    final relationsRequest = await preFetchRelations(modelBlueprint.relations);

    Map<String, dynamic>? record = await fetchRecord(
      table: modelBlueprint.name,
      request: request,
      blueprint: modelBlueprint,
      typeConverters: {
        ...modelBlueprint.typeConverters,
        ...typeConverters,
      },
    );

    if (record != null) {
      final records = await fetchRelations(
        modelBlueprint,
        relationsRequest,
        [record],
      );
      record = records.firstOrNull;
    }

    return ((record != null) ? modelBlueprint.fromRecord(record, this, blueprintOf) : null);
  }

  Future<List<M>> fetchAllWithRequest<M extends BreezeBaseModel>(
    BreezeAbstractFetchRequest request, {
    BreezeModelBlueprint<M>? blueprint,
  }) async {
    final modelBlueprint = blueprint ?? (blueprintOf(M) as BreezeModelBlueprint<M>);

    final relationsRequest = await preFetchRelations(modelBlueprint.relations);

    List<Map<String, dynamic>> records = await fetchAllRecords(
      table: modelBlueprint.name,
      request: request,
      blueprint: modelBlueprint,
      typeConverters: {
        ...modelBlueprint.typeConverters,
        ...typeConverters,
      },
    );

    if (records.isNotEmpty) {
      records = await fetchRelations(
        modelBlueprint,
        relationsRequest,
        records,
      );
    }

    return [
      for (final record in records) modelBlueprint.fromRecord(record, this, blueprintOf),
    ];
  }

  // --- Change API

  Future<M> save<M extends BreezeModel>(M record) => saveWithOptions(record);

  @internal
  Future<M> saveWithOptions<M extends BreezeModel>(
    M record, {
    Map<String, dynamic>? extraData,
  }) async {
    if (!record.isFrozen) {
      await record.beforeSave();
    }

    try {
      if (record.isNew) {
        return add(record, extraData: extraData);
      } else {
        return update(record, extraData: extraData);
      }
    } finally {
      if (!record.isFrozen) {
        await record.afterSave();
      }
    }
  }

  @protected
  Future<M> add<M extends BreezeModel>(
    M record, {
    Map<String, dynamic>? extraData,
  }) async {
    if (!record.isFrozen) {
      final tableName = record.schema.name;
      final keyName = record.schema.key;

      if (keyName == null) {
        throw Exception('The "$M" model does not have a primary key field.');
      }

      final rawRecord = {
        ...record.schema.toRaw(record.toRawRecord(), this, blueprintOf),
        ...?extraData,
      };

      final recordWithoutRelations = await updateRelationsBeforeSave<M>(
        record.schema as BreezeModelBlueprint<M>,
        rawRecord,
        record.schema.relations,
      );

      final newId = await addRecord(name: tableName, key: keyName, record: recordWithoutRelations);

      // TODO: Check key type?
      // if (newId.runtimeType != record.keyType) {
      //   throw Exception('Key type mismatch.');
      // }

      record.id = newId;
      if (record.schema.key != null) {
        rawRecord[record.schema.key!] = newId;
      }

      await updateRelationsAfterSave(
        record.schema as BreezeModelBlueprint<M>,
        rawRecord,
        record.schema.relations,
      );

      _changesController.add(
        BreezeStoreChange(
          store: this,
          type: BreezeStoreChangeType.add,
          entity: tableName,
          id: record.id,
        ),
      );

      record.afterAdd();
    }
    return record;
  }

  @protected
  Future<M> update<M extends BreezeModel>(
    M record, {
    Map<String, dynamic>? extraData,
  }) async {
    // TODO: Check if the recording needs to be saved.
    //  Calculate the hash of record fields (excluding relationships)?
    //  Compare it to the hash stored in the model after a fetch or previous save?

    if (!record.isFrozen) {
      final tableName = record.schema.name;
      final keyName = record.schema.key;
      final keyValue = record.id;

      if (keyName == null) {
        throw Exception('The "$M" model does not have a primary key field.');
      }

      final rawRecord = {
        ...record.schema.toRaw(record.toRawRecord(), this, blueprintOf),
        ...?extraData,
      };

      if (keyValue != null) {
        record.beforeUpdate();

        final recordWithoutRelations = await updateRelationsBeforeSave<M>(
          record.schema as BreezeModelBlueprint<M>,
          rawRecord,
          record.schema.relations,
        );

        await updateRecord(name: tableName, key: keyName, keyValue: keyValue, record: recordWithoutRelations);

        await updateRelationsAfterSave(
          record.schema as BreezeModelBlueprint<M>,
          rawRecord,
          record.schema.relations,
        );

        _changesController.add(
          BreezeStoreChange(
            store: this,
            type: BreezeStoreChangeType.update,
            entity: tableName,
            id: record.id,
          ),
        );

        record.afterUpdate();
      }
    }

    return record;
  }

  Future<M> delete<M extends BreezeModel>(M record) async {
    if (!record.isFrozen) {
      final tableName = record.schema.name;
      final keyName = record.schema.key;
      final keyValue = record.id;

      if (keyName == null) {
        throw Exception('The "$M" model does not have a primary key field.');
      }

      final rawRecord = record.schema.toRaw(record.toRawRecord(), this, blueprintOf);

      if (keyValue != null) {
        record.beforeDelete();

        await deleteRelationsBeforeDelete(
          rawRecord,
          record.schema.relations,
        );

        await deleteRecord(name: tableName, key: keyName, keyValue: keyValue, record: rawRecord);

        record.isFrozen = true;

        await deleteRelationsAfterDelete(
          rawRecord,
          record.schema.relations,
        );

        _changesController.add(
          BreezeStoreChange(
            store: this,
            type: BreezeStoreChangeType.delete,
            entity: tableName,
            id: record.id,
          ),
        );

        record.afterDelete();
      }
    }

    return record;
  }

  /// Deletes records from the store based on the [filter] condition.
  ///
  /// Note: The [beforeDelete] and [afterDelete] model hooks will not
  /// be called when deleting. Related records will also not be processed.
  Future<void> deleteWhere<M extends BreezeModel>({
    required BreezeFilterExpression filter,
  }) async {
    if (M == dynamic) {
      throw Exception('The generic parameter M is required.');
    }

    final modelBlueprint = blueprintOf(M) as BreezeModelBlueprint<M>;
    final tableName = modelBlueprint.name;

    await deleteWhereRecords(name: tableName, filter: filter);

    _changesController.add(
      BreezeStoreChange(
        store: this,
        type: BreezeStoreChangeType.delete,
        entity: tableName,
        id: null,
      ),
    );
  }

  Future<T> count<T extends num>(
    String name,
    String column, {
    BreezeFilterExpression? filter,
  }) => aggregate<T>(
    name,
    BreezeAggregationOp.count,
    column,
    BreezeFetchRequest(filter: filter),
  ).then((value) => (value ?? 0) as T);

  Future<T> sum<T extends num>(
    String name,
    String column, {
    BreezeFilterExpression? filter,
  }) => aggregate<T>(
    name,
    BreezeAggregationOp.sum,
    column,
    BreezeFetchRequest(filter: filter),
  ).then((value) => (value ?? 0) as T);

  Future<T?> average<T extends num>(
    String name,
    String column, {
    BreezeFilterExpression? filter,
  }) => aggregate<T>(
    name,
    BreezeAggregationOp.avg,
    column,
    BreezeFetchRequest(filter: filter),
  );

  Future<T?> min<T extends num>(
    String name,
    String column, {
    BreezeFilterExpression? filter,
  }) => aggregate<T>(
    name,
    BreezeAggregationOp.min,
    column,
    BreezeFetchRequest(filter: filter),
  );

  Future<T?> max<T extends num>(
    String name,
    String column, {
    BreezeFilterExpression? filter,
  }) => aggregate<T>(
    name,
    BreezeAggregationOp.max,
    column,
    BreezeFetchRequest(filter: filter),
  );

  // Relations

  @protected
  Future<BreezeFetchRelationsRequest> preFetchRelations(Set<BreezeModelRelation> relations);

  @protected
  Future<List<Map<String, dynamic>>> fetchRelations<M extends BreezeBaseModel>(
    BreezeModelBlueprint<M> blueprint,
    BreezeFetchRelationsRequest request,
    List<Map<String, dynamic>> records,
  );

  @protected
  Future<Map<String, dynamic>> updateRelationsBeforeSave<M extends BreezeBaseModel>(
    BreezeModelBlueprint<M> blueprint,
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  );

  @protected
  Future<void> updateRelationsAfterSave<M extends BreezeBaseModel>(
    BreezeModelBlueprint<M> blueprint,
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  );

  @protected
  Future<void> deleteRelationsBeforeDelete(
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  );

  @protected
  Future<void> deleteRelationsAfterDelete(
    Map<String, dynamic> record,
    Set<BreezeModelRelation> relations,
  );

  // --- To implement

  Future<void> close() async {}

  Future<BreezeDataRecord?> fetchRecord({
    required String table,
    required BreezeAbstractFetchRequest request,
    BreezeModelBlueprint? blueprint,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  });

  Future<List<BreezeDataRecord>> fetchAllRecords({
    required String table,
    BreezeAbstractFetchRequest? request,
    BreezeModelBlueprint? blueprint,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  });

  Future<dynamic> fetchColumnWithRequest({
    required String table,
    required String column,
    required BreezeAbstractFetchRequest request,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  });

  Future<List> fetchColumnAllWithRequest({
    required String table,
    required String column,
    required BreezeAbstractFetchRequest request,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  });

  @protected
  Future<dynamic> addRecord({
    required String name,
    String? key,
    required Map<String, dynamic> record,
  });

  @protected
  Future<void> addRecords({
    required String name,
    String? key,
    required List<Map<String, dynamic>> records,
  }) async {
    await Future.wait(
      records.map((record) => addRecord(name: name, key: key, record: record)),
    );
  }

  @protected
  Future<void> updateRecord({
    required String name,
    required String key,
    required dynamic keyValue,
    required Map<String, dynamic> record,
  });

  @protected
  Future<void> deleteRecord({
    required String name,
    required String key,
    required dynamic keyValue,
    required Map<String, dynamic> record,
  });

  @protected
  Future<void> deleteWhereRecords({
    required String name,
    required BreezeFilterExpression filter,
  });

  @protected
  Future<T?> aggregate<T extends num>(
    String name,
    BreezeAggregationOp op,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]);
}

/*
class BreezeBlueprintNotFoundError extends ArgumentError {
  BreezeBlueprintNotFoundError(Type modelType)
    : super(
        'The blueprint for model "$modelType" is not defined. '
            'You most likely forgot to specify it in the `models` parameter when creating the store.',
        'blueprint',
      );
}
*/

class BreezeBlueprintNotFoundException extends BreezeException {
  const BreezeBlueprintNotFoundException(Type modelType)
    : super(
        'The blueprint for model "$modelType" is not defined.\n'
        'You most likely forgot to specify it in the `models` parameter when creating the store.',
      );
}
