import 'dart:async';
import 'package:databreeze/src/migration/migration_strategy.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:databreeze/src/store_change.dart';
import 'package:databreeze/src/type_converters.dart';
import 'package:databreeze/src/types.dart';
import 'package:meta/meta.dart';

enum BreezeAggregationOp { count, avg, min, max }

abstract class BreezeStore with BreezeStorageTypeConverters {
  final Map<Type, BreezeModelBlueprint> blueprints;

  final BreezeMigrationStrategy? migrationStrategy;

  @override
  late final Set<BreezeBaseTypeConverter> typeConverters;

  Set<BreezeBaseTypeConverter> get defaultTypeConverters => {};

  BreezeStore({
    Set<BreezeModelBlueprint> models = const {},
    this.migrationStrategy,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  }) : blueprints = Map.fromIterable(models, key: (b) => b.type) {
    this.typeConverters = {...defaultTypeConverters, ...typeConverters};
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

  Future<int> count(
    String entity,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) => aggregate<int>(entity, BreezeAggregationOp.count, column, request).then((value) => value ?? 0);

  Future<num> average(
    String entity,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) => aggregate<num>(entity, BreezeAggregationOp.avg, column, request).then((value) => value ?? 0);

  Future<num> min(
    String entity,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) => aggregate<num>(entity, BreezeAggregationOp.min, column, request).then((value) => value ?? 0);

  Future<num> max(
    String entity,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) => aggregate<num>(entity, BreezeAggregationOp.max, column, request).then((value) => value ?? 0);

  Future<void> close() async {}

  // --- To implement

  Future<BreezeDataRecord?> fetchRecord({
    required String table,
    required BreezeAbstractFetchRequest request,
    BreezeModelBlueprint? blueprint,
    // required BreezeFilterExpression filter,
    // List<BreezeSortBy> sortBy = const [],
  });

  Future<List<BreezeDataRecord>> fetchAllRecords({
    required String table,
    BreezeAbstractFetchRequest? request,
    BreezeModelBlueprint? blueprint,
    // BreezeFilterExpression? filter,
    // List<BreezeSortBy> sortBy = const [],
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
  Future<T?> aggregate<T>(
    String entity,
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
