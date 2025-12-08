import 'dart:async';
import 'package:databreeze/src/migration/migration_strategy.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:databreeze/src/store_change.dart';
import 'package:databreeze/src/type_converters.dart';
import 'package:databreeze/src/types.dart';
import 'package:meta/meta.dart';

enum BreezeAggregationOp { count, sum, avg, min, max }

typedef BreezeStoreErrorCallback = void Function(Object error, StackTrace? stackTrace);

abstract class BreezeStore with BreezeStorageTypeConverters {
  final Map<Type, BreezeModelBlueprint> blueprints;

  final BreezeMigrationStrategy? migrationStrategy;

  final BreezeStoreErrorCallback? onError;

  @override
  late final Set<BreezeBaseTypeConverter> typeConverters;

  Set<BreezeBaseTypeConverter> get defaultTypeConverters => {};

  BreezeStore({
    Set<BreezeModelBlueprint> models = const {},
    this.migrationStrategy,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
    this.onError,
  }) : blueprints = Map.fromIterable(models, key: (b) => b.type) {
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

  // --- API

  Future<M?> fetchWithRequest<M extends BreezeBaseModel>(
    BreezeAbstractFetchRequest request, {
    BreezeModelBlueprint<M>? blueprint,
  }) async {
    final modelBlueprint = blueprint ?? (blueprintOf(M) as BreezeModelBlueprint<M>);

    final record = await fetchRecord(
      table: modelBlueprint.name,
      request: request,
      blueprint: modelBlueprint,
      typeConverters: {
        ...modelBlueprint.typeConverters,
        ...typeConverters,
      },
    );

    return ((record != null) ? modelBlueprint.fromRecord(record, this) : null);
  }

  Future<List<M>> fetchAllWithRequest<M extends BreezeBaseModel>(
    BreezeAbstractFetchRequest request, {
    BreezeModelBlueprint<M>? blueprint,
  }) async {
    final modelBlueprint = blueprint ?? (blueprintOf(M) as BreezeModelBlueprint<M>);

    final records = await fetchAllRecords(
      table: modelBlueprint.name,
      request: request,
      blueprint: modelBlueprint,
      typeConverters: {
        ...modelBlueprint.typeConverters,
        ...typeConverters,
      },
    );

    return [
      for (final record in records) modelBlueprint.fromRecord(record, this),
    ];
  }

  Future<M> save<M extends BreezeModel>(M record) async {
    if (record.isNew) {
      return add(record);
    } else {
      return update(record);
    }
  }

  @protected
  Future<M> add<M extends BreezeModel>(M record) async {
    if (!record.isFrozen) {
      final tableName = record.schema.name;
      final keyName = record.schema.key;

      if (keyName == null) {
        throw Exception('The "$M" model does not have a primary key field.');
      }

      final rawRecord = record.schema.toRaw(record.toRawRecord(), this);
      final newId = await addRecord(name: tableName, key: keyName, record: rawRecord);

      // TODO: Check key type?
      // if (newId.runtimeType != record.keyType) {
      //   throw Exception('Key type mismatch.');
      // }

      record.id = newId;

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
  Future<M> update<M extends BreezeModel>(M record) async {
    if (!record.isFrozen) {
      final tableName = record.schema.name;
      final keyName = record.schema.key;
      final keyValue = record.id;

      if (keyName == null) {
        throw Exception('The "$M" model does not have a primary key field.');
      }

      final rawRecord = record.schema.toRaw(record.toRawRecord(), this);

      if (keyValue != null) {
        record.beforeUpdate();

        await updateRecord(name: tableName, key: keyName, keyValue: keyValue, record: rawRecord);

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

      final rawRecord = record.schema.toRaw(record.toRawRecord(), this);

      if (keyValue != null) {
        record.beforeDelete();

        await deleteRecord(name: tableName, key: keyName, keyValue: keyValue, record: rawRecord);

        record.isFrozen = true;

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

  Future<T> count<T extends num>(
    String name,
    String column, [
    // TODO: filter & sortBy or request?
    BreezeAbstractFetchRequest? request,
  ]) => aggregate<T>(name, BreezeAggregationOp.count, column, request).then((value) => (value ?? 0) as T);

  Future<T> sum<T extends num>(
    String name,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) => aggregate<T>(name, BreezeAggregationOp.sum, column, request).then((value) => (value ?? 0) as T);

  Future<T?> average<T extends num>(
    String name,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) => aggregate<T>(name, BreezeAggregationOp.avg, column, request);

  Future<T?> min<T extends num>(
    String name,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) => aggregate<T>(name, BreezeAggregationOp.min, column, request);

  Future<T?> max<T extends num>(
    String name,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) => aggregate<T>(name, BreezeAggregationOp.max, column, request);

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

  @protected
  Future<dynamic> addRecord({
    required String name,
    required String key,
    required Map<String, dynamic> record,
  });

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
