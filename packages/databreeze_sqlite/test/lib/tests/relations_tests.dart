import 'package:collection/collection.dart';
import 'package:databreeze/databreeze.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../models/actor.dart';
import '../models/article.dart';
import '../models/article_tag.dart';
import '../models/item.dart';
import '../models/item_category.dart';
import '../models/movie.dart';

part '_utils.dart';
part '_test_store.dart';
part '_test_belongsto_fetch.dart';
part '_test_hasmany_fetch.dart';
part '_test_hasmanythrough_fetch.dart';

// @isTest
Future<void> testFetchHasOneRelation({
  required BreezeTestStore store,
}) async {
  // TODO:
}

// @isTest
Future<void> testUpdateHasOneRelation({
  required BreezeTestStore store,
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
      RelationTests.hasOne: [
        // (
        //   label: 'fetch',
        //   models: {ItemModel.blueprint, ItemCategoryModel.blueprint},
        //   test: testFetchHasOneRelation,
        // ),
      ],
      RelationTests.hasMany: [
        (
          label: 'fetchOne',
          models: {ArticleModel.blueprint, ArticleTagModel.blueprint},
          test: testFetchOneHasManyRelation,
        ),
      ],
      RelationTests.belongsTo: [
        (
          label: 'fetchOne',
          models: {ItemModel.blueprint, ItemCategoryModel.blueprint},
          test: testFetchOneBelongsToRelation,
        ),
        (
          label: 'fetchAll',
          models: {ItemModel.blueprint, ItemCategoryModel.blueprint},
          test: testFetchAllBelongsToRelation,
        ),
      ],
      RelationTests.hasManyThrough: [
        (
          label: 'fetchAll',
          models: {ActorModel.blueprint, MovieModel.blueprint},
          test: testFetchAllHasManyThroughRelation,
        ),
      ],
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
