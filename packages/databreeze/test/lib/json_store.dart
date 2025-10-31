import 'package:collection/collection.dart';
import 'package:databreeze/databreeze.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'model_types.dart';

class JsonStore extends BreezeStore {
  static const _latency = Duration(milliseconds: 500);

  final Logger? log;

  @protected
  @visibleForTesting
  int lastId = 1;

  @protected
  @visibleForTesting
  final Map<int, Map<String, dynamic>> records;

  final bool simulateLatency;

  JsonStore({
    this.log,
    Map<int, Map<String, dynamic>>? records,
    super.typeConverters,
    this.simulateLatency = false,
  }) : records = records ?? {};

  @override
  Future<BreezeDataRecord?> fetchRecord({
    required String table,
    BreezeModelBlueprint? blueprint,
    required BreezeFetchOptions options,
  }) async {
    if (simulateLatency) {
      // Simulate latency
      await Future.delayed(_latency);
    }

    final record = records.values.firstWhereOrNull((entry) => applyFilter(entry, options.filter));

    log?.finest('Fetch $options: $record');

    return record;
  }

  @override
  Future<List<BreezeDataRecord>> fetchAllRecords({
    required String table,
    BreezeModelBlueprint? blueprint,
    BreezeFetchOptions? options,
  }) async {
    if (simulateLatency) {
      // Simulate latency
      await Future.delayed(_latency);
    }

    var result = records.values;
    if (options != null) {
      result = result.where((entry) => applyFilter(entry, options.filter));
    }

    log?.finest('Fetch All $options: $result');

    return result.toList(growable: false);
  }

  @override
  Future<dynamic> addRecord({
    required String name,
    required String key,
    required Map<String, dynamic> record,
  }) async {
    if (simulateLatency) {
      // Simulate latency
      await Future.delayed(_latency);
    }

    final newId = lastId++;
    final newRecord = {
      ...record,
      key: newId,
    };

    records[newId] = newRecord;

    log?.finest('Add #$newId: $newRecord');

    return newId;
  }

  @override
  Future<void> updateRecord({
    required String name,
    required String key,
    required dynamic keyValue,
    required Map<String, dynamic> record,
  }) async {
    if (simulateLatency) {
      // Simulate latency
      await Future.delayed(_latency);
    }

    records[keyValue] = record;

    log?.finest('Update #$keyValue: $record');
  }

  @override
  Future<void> deleteRecord({
    required String name,
    required String key,
    required dynamic keyValue,
    required Map<String, dynamic> record,
  }) async {
    if (simulateLatency) {
      // Simulate latency
      await Future.delayed(_latency);
    }

    records.remove(keyValue);

    log?.finest('Delete #$keyValue: $record');
  }

  @override
  Future<T?> aggregate<T>(String entity, BreezeAggregationOp op, String column, [BreezeFetchOptions? options]) {
    // TODO: implement aggregate
    throw UnimplementedError();
  }

  @protected
  bool applyFilter(Map<String, dynamic> entry, BreezeFilterExpression? filter) {
    if (filter is BreezeComparisonFilter) {
      final value = entry[filter.field];
      switch (filter.operator) {
        case '==':
          return value == filter.value;
        case '!=':
          return value != filter.value;
        case '<':
          return switch (value) {
            Comparable comparableValue => comparableValue.compareTo(filter.value) < 0,
            _ => false,
          };
        case '<=':
          return switch (value) {
            Comparable comparableValue => comparableValue.compareTo(filter.value) <= 0,
            _ => false,
          };
        case '>':
          return switch (value) {
            Comparable comparableValue => comparableValue.compareTo(filter.value) > 0,
            _ => false,
          };
        case '>=':
          return switch (value) {
            Comparable comparableValue => comparableValue.compareTo(filter.value) >= 0,
            _ => false,
          };
        default:
          throw UnsupportedError('Unknown operator: ${filter.operator}');
      }
    } else if (filter is BreezeBetweenFilter) {
      final value = entry[filter.field];
      return switch (value) {
        Comparable comparableValue =>
          comparableValue.compareTo(filter.min) >= 0 && comparableValue.compareTo(filter.max) <= 0,
        _ => false,
      };
    } else if (filter is BreezeInFilter) {
      final value = entry[filter.field];
      return !filter.inverse ? filter.values.contains(value) : !filter.values.contains(value);
    } else if (filter is BreezeAndFilter) {
      return applyFilter(entry, filter.left) && applyFilter(entry, filter.right);
    } else if (filter is BreezeOrFilter) {
      return applyFilter(entry, filter.left) || applyFilter(entry, filter.right);
    } else {
      throw UnsupportedError('Unknown filter type: $filter');
    }
  }
}
