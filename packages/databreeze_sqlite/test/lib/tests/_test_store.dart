part of 'relations_tests.dart';

class BreezeTestStoreField {
  final Type type;
  final bool isPrimaryKey;
  final bool isNullable;

  const BreezeTestStoreField({
    required this.type,
    this.isPrimaryKey = false,
    this.isNullable = false,
  });
}

abstract mixin class BreezeTestStore implements BreezeStore {
  @override
  @visibleForTesting
  Future<dynamic> addRecord({
    required String name,
    String? key,
    required Map<String, dynamic> record,
  });

  @override
  @visibleForTesting
  Future<void> addRecords({
    required String name,
    String? key,
    required List<Map<String, dynamic>> records,
  });

  @override
  @visibleForTesting
  Future<void> updateRecord({
    required String name,
    required String key,
    required dynamic keyValue,
    required Map<String, dynamic> record,
  });

  @override
  @visibleForTesting
  Future<void> deleteRecord({
    required String name,
    required String key,
    required dynamic keyValue,
    required Map<String, dynamic> record,
  });

  @protected
  @visibleForTesting
  Future<void> createCollection(
    String name,
    Map<String, BreezeTestStoreField> fields,
  );

  @protected
  @visibleForTesting
  Future<void> initCollection(
    String name,
    Map<String, BreezeTestStoreField> fields,
    List<Map<String, dynamic>> records,
  ) async {
    final key = fields.entries.firstWhereOrNull((e) => e.value.isPrimaryKey)?.key;
    await createCollection(name, fields);
    if (records.isNotEmpty) {
      await addRecords(name: name, key: key, records: records);
    }
  }
}
