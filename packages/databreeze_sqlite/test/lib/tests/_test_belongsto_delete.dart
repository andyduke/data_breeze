part of 'relations_tests.dart';

Future<void> testDeleteBelongsToRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'item_categories',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 1,
        'name': 'Category 1',
      },
      {
        'id': 2,
        'name': 'Category 2',
      },
    ],
  );
  await store.initCollection(
    'items',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
      'category_id': BreezeTestStoreField(type: int, isNullable: true),
    },
    [
      {
        'id': 1,
        'name': 'Item 1',
        'category_id': 1,
      },
      {
        'id': 2,
        'name': 'Item 2',
        'category_id': 2,
      },
    ],
  );

  final query = BreezeQueryById<Item>(1);
  final item = await query.fetch(store);

  expect(item, isNotNull);
  expect(item!.category, isA<ItemCategory>());

  await store.delete(item);

  final items = await store.fetchAllRecords(table: 'items');
  expect(
    items,
    equals([
      {
        'id': 2,
        'name': 'Item 2',
        'category_id': 2,
      },
    ]),
  );

  final itemCategories = await store.fetchAllRecords(table: 'item_categories');
  expect(
    itemCategories,
    equals([
      {
        'id': 1,
        'name': 'Category 1',
      },
      {
        'id': 2,
        'name': 'Category 2',
      },
    ]),
  );
}
