import 'package:collection/collection.dart';
import 'package:databreeze/databreeze.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../models/actor.dart';
import '../models/company_address.dart';
import '../models/article.dart';
import '../models/article_tag.dart';
import '../models/company.dart';
import '../models/item.dart';
import '../models/item_category.dart';
import '../models/movie.dart';

part '_utils.dart';
part '_test_store.dart';
part '_test_hasone_fetch.dart';
part '_test_belongsto_fetch.dart';
part '_test_hasmany_fetch.dart';
part '_test_hasmanythrough_fetch.dart';
part '_test_hasone_update.dart';
part '_test_hasmany_update.dart';

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
        (
          label: 'fetchOne',
          models: {CompanyModel.blueprint, CompanyAddressModel.blueprint},
          test: testFetchOneHasOneRelation,
        ),
        (
          label: 'fetchAll',
          models: {CompanyModel.blueprint, CompanyAddressModel.blueprint},
          test: testFetchAllHasOneRelation,
        ),
      ],
      RelationTests.hasMany: [
        (
          label: 'fetchOne',
          models: {ArticleModel.blueprint, ArticleTagModel.blueprint},
          test: testFetchOneHasManyRelation,
        ),
        (
          label: 'fetchAll',
          models: {ArticleModel.blueprint, ArticleTagModel.blueprint},
          test: testFetchAllHasManyRelation,
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
          label: 'fetchOne',
          models: {ActorModel.blueprint, MovieModel.blueprint},
          test: testFetchOneHasManyThroughRelation,
        ),
        (
          label: 'fetchAll',
          models: {ActorModel.blueprint, MovieModel.blueprint},
          test: testFetchAllHasManyThroughRelation,
        ),
      ],
    },
  );

  // TODO: Add/Update/Delete records with relations
  defineRelationGroup(
    '$description Change',
    relations: relations,
    store: store,
    tests: {
      RelationTests.hasOne: [
        (
          label: 'Add',
          models: {CompanyModel.blueprint, CompanyAddressModel.blueprint},
          test: testAddHasOneRelation,
        ),
        (
          label: 'Update',
          models: {CompanyModel.blueprint, CompanyAddressModel.blueprint},
          test: testUpdateHasOneRelation,
        ),
      ],
      RelationTests.hasMany: [
        (
          label: 'Add',
          models: {ArticleModel.blueprint, ArticleTagModel.blueprint},
          test: testAddHasManyRelation,
        ),
        (
          label: 'Update',
          models: {ArticleModel.blueprint, ArticleTagModel.blueprint},
          test: testUpdateHasManyRelation,
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
