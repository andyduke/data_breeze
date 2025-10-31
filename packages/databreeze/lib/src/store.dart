import 'dart:async';
import 'package:databreeze/src/fetch_options.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/store_change.dart';
import 'package:databreeze/src/type_converters.dart';
import 'package:databreeze/src/types.dart';
import 'package:meta/meta.dart';

enum BreezeAggregationOp { count, avg, min, max }

abstract class BreezeStore with BreezeStorageTypeConverters {
  @override
  late final Set<BreezeTypeConverter> typeConverters;

  Set<BreezeTypeConverter> get defaultTypeConverters => {};

  BreezeStore({
    Set<BreezeTypeConverter> typeConverters = const {},
  }) {
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

  // --- API

  Future<M?> fetch<M>({
    required BreezeModelBlueprint blueprint,
    required BreezeFetchOptions options,
  }) async {
    final record = await fetchRecord(
      table: blueprint.name,
      blueprint: blueprint,
      options: options,
    );

    return ((record != null) ? blueprint.fromRecord<M>(record, this) : null);
  }

  Future<List<M>> fetchAll<M>({
    required BreezeModelBlueprint blueprint,
    BreezeFetchOptions? options,
  }) async {
    final records = await fetchAllRecords(
      table: blueprint.name,
      blueprint: blueprint,
      options: options,
    );

    return [
      for (final record in records) blueprint.fromRecord<M>(record, this),
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
      final rawRecord = record.schema.toRaw(record.toRecord(), this);

      final newId = await addRecord(name: tableName, key: keyName, record: rawRecord);

      // TODO: Check key type
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
      final rawRecord = record.schema.toRaw(record.toRecord(), this);

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
      final rawRecord = record.schema.toRaw(record.toRecord(), this);

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

  Future<int> count(String entity, String column, [BreezeFetchOptions? options]) =>
      aggregate<int>(entity, BreezeAggregationOp.count, column, options).then((value) => value ?? 0);

  Future<num> average(String entity, String column, [BreezeFetchOptions? options]) =>
      aggregate<num>(entity, BreezeAggregationOp.avg, column, options).then((value) => value ?? 0);

  Future<num> min(String entity, String column, [BreezeFetchOptions? options]) =>
      aggregate<num>(entity, BreezeAggregationOp.min, column, options).then((value) => value ?? 0);

  Future<num> max(String entity, String column, [BreezeFetchOptions? options]) =>
      aggregate<num>(entity, BreezeAggregationOp.max, column, options).then((value) => value ?? 0);

  Future<void> close() async {}

  // --- To implement

  Future<BreezeDataRecord?> fetchRecord({
    required String table,
    BreezeModelBlueprint? blueprint,
    required BreezeFetchOptions options,
  });

  Future<List<BreezeDataRecord>> fetchAllRecords({
    required String table,
    BreezeModelBlueprint? blueprint,
    BreezeFetchOptions? options,
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
  Future<T?> aggregate<T>(String entity, BreezeAggregationOp op, String column, [BreezeFetchOptions? options]);
}
