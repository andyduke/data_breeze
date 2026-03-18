part of 'relations_tests.dart';

Future<void> testFetchOneBelongsToRelation({
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
  expect(item!.id, equals(1));
  expect(item.name, equals('Item 1'));
  expect(item.category, isNotNull);
  expect(item.category, isA<ItemCategory>());
  expect(item.category!.name, equals('Category 1'));
}

Future<void> testFetchAllBelongsToRelation({
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
      'category_id': BreezeTestStoreField(type: int),
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
        'category_id': 1,
      },
      {
        'id': 3,
        'name': 'Item 3',
        'category_id': 2,
      },
    ],
  );

  final query = BreezeQueryAll<Item>();
  final items = await query.fetch(store);

  expect(items, hasLength(3));

  expect(items[0].id, equals(1));
  expect(items[0].name, equals('Item 1'));
  expect(items[0].category, isNotNull);
  expect(items[0].category, isA<ItemCategory>());
  expect(items[0].category!.name, equals('Category 1'));

  expect(items[1].id, equals(2));
  expect(items[1].name, equals('Item 2'));
  expect(items[1].category, isNotNull);
  expect(items[1].category, isA<ItemCategory>());
  expect(items[1].category!.name, equals('Category 1'));

  expect(items[2].id, equals(3));
  expect(items[2].name, equals('Item 3'));
  expect(items[2].category, isNotNull);
  expect(items[2].category, isA<ItemCategory>());
  expect(items[2].category!.name, equals('Category 2'));
}
