import 'package:collection/collection.dart';
import 'package:databreeze/databreeze.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

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
    super.models,
    Map<int, Map<String, dynamic>>? records,
    super.typeConverters,
    this.simulateLatency = false,
  }) : records = records ?? {};

  @override
  Future<BreezeDataRecord?> fetchRecord({
    required String table,
    BreezeModelBlueprint? blueprint,
    required BreezeFilterExpression filter,
    List<BreezeSortBy> sortBy = const [],
  }) async {
    if (simulateLatency) {
      // Simulate latency
      await Future.delayed(_latency);
    }

    Iterable<Map<String, dynamic>> allRecords = records.values;
    if (sortBy.isNotEmpty) {
      allRecords = allRecords.sorted((a, b) => applySort(a, b, sortBy));
    }

    final record = allRecords.firstWhereOrNull((entry) => applyFilter(entry, filter));

    log?.finest('Fetch $filter: $record');

    return record;
  }

  @override
  Future<List<BreezeDataRecord>> fetchAllRecords({
    required String table,
    BreezeModelBlueprint? blueprint,
    BreezeFilterExpression? filter,
    List<BreezeSortBy> sortBy = const [],
  }) async {
    if (simulateLatency) {
      // Simulate latency
      await Future.delayed(_latency);
    }

    Iterable<Map<String, dynamic>> allRecords = records.values;
    if (sortBy.isNotEmpty) {
      allRecords = allRecords.sorted((a, b) => applySort(a, b, sortBy));
    }

    var result = allRecords;
    if (filter != null) {
      result = result.where((entry) => applyFilter(entry, filter));
    }

    log?.finest('Fetch All $filter: $result');

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
  Future<T?> aggregate<T>(
    String entity,
    BreezeAggregationOp op,
    String column, [
    BreezeFilterExpression? filter,
    List<BreezeSortBy> sortBy = const [],
  ]) {
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
    } else if (filter == null) {
      // Do nothing
      return true;
    } else {
      throw UnsupportedError('Unknown filter type: $filter');
    }
  }

  @protected
  int applySort(Map<String, dynamic> a, Map<String, dynamic> b, List<BreezeSortBy> sortBy) {
    for (final order in sortBy) {
      int cmp = compare(a[order.column], b[order.column], inverse: order.direction == BreezeSortDir.desc);
      if (cmp != 0) return cmp;
    }
    return 0;
  }

  @protected
  int compare(dynamic a, dynamic b, {bool inverse = false}) {
    final mul = inverse ? -1 : 1;
    if (a is Comparable) {
      return mul * a.compareTo(b);
    } else {
      return mul * ((a == b) ? 0 : (a > b ? 1 : -1));
    }
  }
}
