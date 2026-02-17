import 'package:databreeze/databreeze.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:databreeze_flutter/databreeze_flutter.dart';

class MockStore extends BreezeStore {
  @override
  Future addRecord({required String name, required String key, required Map<String, dynamic> record}) {
    // TODO: implement addRecord
    throw UnimplementedError();
  }

  @override
  Future<T?> aggregate<T extends num>(
    String name,
    BreezeAggregationOp op,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) {
    // TODO: implement aggregate
    throw UnimplementedError();
  }

  @override
  Future<void> deleteRecord({
    required String name,
    required String key,
    required keyValue,
    required Map<String, dynamic> record,
  }) {
    // TODO: implement deleteRecord
    throw UnimplementedError();
  }

  @override
  Future<List<BreezeDataRecord>> fetchAllRecords({
    required String table,
    BreezeAbstractFetchRequest? request,
    BreezeModelBlueprint<BreezeBaseModel>? blueprint,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  }) {
    // TODO: implement fetchAllRecords
    throw UnimplementedError();
  }

  @override
  Future<BreezeDataRecord?> fetchRecord({
    required String table,
    required BreezeAbstractFetchRequest request,
    BreezeModelBlueprint<BreezeBaseModel>? blueprint,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  }) {
    // TODO: implement fetchRecord
    throw UnimplementedError();
  }

  @override
  Future<dynamic> fetchColumnWithRequest({
    required String table,
    required String column,
    required BreezeAbstractFetchRequest request,
    Set<BreezeBaseTypeConverter<dynamic, dynamic>> typeConverters = const {},
  }) async {
    // TODO: implement fetchColumnWithRequest
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> fetchColumnAllWithRequest({
    required String table,
    required String column,
    required BreezeAbstractFetchRequest request,
    Set<BreezeBaseTypeConverter<dynamic, dynamic>> typeConverters = const {},
  }) async {
    // TODO: implement fetchAllColumnWithRequest
    throw UnimplementedError();
  }

  @override
  Future<void> updateRecord({
    required String name,
    required String key,
    required keyValue,
    required Map<String, dynamic> record,
  }) {
    // TODO: implement updateRecord
    throw UnimplementedError();
  }
}

class MockBreezeDataQueryController<T> extends BreezeDataQueryController<T> {
  final T mockResult;

  MockBreezeDataQueryController({
    required super.source,
    required super.query,
    super.autoUpdate,
    super.refetchOnAutoUpdate,
    required this.mockResult,
  });

  @override
  Future<T> doFetch([bool isReload = false]) async => mockResult;
}

class Item extends BreezeModel<int> {
  final String name;

  Item({
    required this.name,
  });

  @override
  BreezeModelBlueprint<BreezeBaseModel> get schema => throw UnimplementedError();

  @override
  Map<String, dynamic> toRecord() {
    throw UnimplementedError();
  }
}

Future<void> main() async {
  test('BreezeResultList<T>', () async {
    final item = Item(name: 'Test');
    final controller = MockBreezeDataQueryController<List<Item>>(
      source: MockStore(),
      query: BreezeQueryAll<Item>(),
      mockResult: [item],
      autoUpdate: false,
    );

    await controller.fetch();

    expect(controller.result?.find((item) => item.name == 'Test'), equals(item));
  });
}
