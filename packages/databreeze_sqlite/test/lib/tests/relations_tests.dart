import 'package:databreeze/databreeze.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../models/item.dart';
import '../models/item_category.dart';

part '_utils.dart';
part '_test_store.dart';

// @isTest
Future<void> testFetchHasOneRelation({
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

// @isTest
Future<void> testFetchHasManyRelation({
  required BreezeStore store,
}) async {
  // TODO:
  expect(store, isNotNull);
}

// @isTest
Future<void> testFetchBelongsToRelation({
  required BreezeStore store,
}) async {
  // TODO:
}

// @isTest
Future<void> testFetchHasManyThroughRelation({
  required BreezeStore store,
}) async {
  // TODO:
}

// @isTest
Future<void> testUpdateHasOneRelation({
  required BreezeStore store,
}) async {
  // TODO:
  expect(store, isNotNull);
}

@isTestGroup
void relationsGroup(
  String description, {
  required BreezeTestStoreGetter store,
  Set<RelationTests> relations = const {...RelationTests.values},
}) {
  defineRelationGroup(
    '$description Fetch with',
    relations: relations,
    store: store,
    tests: {
      RelationTests.hasOne: (
        models: {ItemModel.blueprint, ItemCategoryModel.blueprint},
        test: testFetchHasOneRelation,
      ),
      RelationTests.hasMany: (models: {}, test: testFetchHasManyRelation),
      RelationTests.belongsTo: (models: {}, test: testFetchBelongsToRelation),
      RelationTests.hasManyThrough: (models: {}, test: testFetchHasManyThroughRelation),
    },
  );

  /*
  _defineRelationGroup(
    '$description Update',
    store: store,
    relations: relations,
    tests: {
      RelationTests.hasOne: testUpdateHasOneRelation,
      // RelationTests.hasMany: testFetchHasManyRelation,
      // RelationTests.belongsTo: testFetchBelongsToRelation,
      // RelationTests.hasManyThrough: testFetchHasManyThroughRelation,
    },
  );
  */
}
