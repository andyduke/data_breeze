part of 'relations_tests.dart';

Future<void> testAddBelongsToRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'item_categories',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
    },
    [],
  );
  await store.initCollection(
    'items',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
      'category_id': BreezeTestStoreField(type: int),
    },
    [],
  );

  final item = Item(
    name: 'Item 1',
    category: ItemCategory(
      name: 'Category 1',
    ),
  );

  await store.save(item);

  expect(item.isNew, isFalse);
  expect(item.id, isNotNull);

  expect(item.category, isNotNull);
  expect(item.category!.isNew, isFalse);
  expect(item.category!.id, isNotNull);

  final items = await store.fetchAllRecords(table: 'items');
  expect(
    items,
    equals([
      {
        'id': 1,
        'name': 'Item 1',
        'category_id': 1,
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
    ]),
  );
}

Future<void> testUpdateBelongsToRelation({
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
    ],
  );
  await store.initCollection(
    'items',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
      'category_id': BreezeTestStoreField(type: int),
    },
    [
      {
        'id': 1,
        'name': 'Item 1',
        'category_id': 1,
      },
    ],
  );

  final query = BreezeQueryById<Item>(1);
  final item = await query.fetch(store);

  expect(item, isNotNull);
  expect(item!.category, isA<ItemCategory>());

  item.name = 'Item 1*';
  item.category?.name = 'Category 1*';
  await store.save(item);

  final items = await store.fetchAllRecords(table: 'items');
  expect(
    items,
    equals([
      {
        'id': 1,
        'name': 'Item 1*',
        'category_id': 1,
      },
    ]),
  );

  final itemCategories = await store.fetchAllRecords(table: 'item_categories');
  expect(
    itemCategories,
    equals([
      {
        'id': 1,
        'name': 'Category 1*',
      },
    ]),
  );
}
