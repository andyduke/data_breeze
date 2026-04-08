import 'package:collection/collection.dart';
import 'package:databreeze/databreeze.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../models/actor.dart';
import '../models/company_address.dart';
import '../models/article.dart';
import '../models/article_tag.dart';
import '../models/company.dart';
import '../models/department.dart';
import '../models/employee.dart';
import '../models/item.dart';
import '../models/item_category.dart';
import '../models/movie.dart';
import '../models/person.dart';
import '../models/person_passport.dart';

part '_utils.dart';
part '_test_store.dart';
part '_test_hasone_fetch.dart';
part '_test_hasone_update.dart';
part '_test_hasone_delete.dart';
part '_test_belongsto_fetch.dart';
part '_test_belongsto_update.dart';
part '_test_belongsto_delete.dart';
part '_test_hasmany_fetch.dart';
part '_test_hasmany_update.dart';
part '_test_hasmany_delete.dart';
part '_test_hasmanythrough_fetch.dart';
part '_test_hasmanythrough_update.dart';
part '_test_hasmanythrough_delete.dart';

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
      RelationTests.oneToOne: [
        (
          label: 'fetchSingle',
          models: {CompanyModel.blueprint, CompanyAddressModel.blueprint},
          test: testFetchOneHasOneRelation,
        ),
        (
          label: 'fetchAll',
          models: {CompanyModel.blueprint, CompanyAddressModel.blueprint},
          test: testFetchAllHasOneRelation,
        ),
      ],
      RelationTests.oneToMany: [
        (
          label: 'fetchSingle',
          models: {ArticleModel.blueprint, ArticleTagModel.blueprint},
          test: testFetchOneHasManyRelation,
        ),
        (
          label: 'fetchAll',
          models: {ArticleModel.blueprint, ArticleTagModel.blueprint},
          test: testFetchAllHasManyRelation,
        ),
      ],
      RelationTests.manyToOne: [
        (
          label: 'fetchSingle',
          models: {ItemModel.blueprint, ItemCategoryModel.blueprint},
          test: testFetchOneBelongsToRelation,
        ),
        (
          label: 'fetchAll',
          models: {ItemModel.blueprint, ItemCategoryModel.blueprint},
          test: testFetchAllBelongsToRelation,
        ),
      ],
      RelationTests.manyToMany: [
        (
          label: 'fetchSingle',
          models: {ActorModel.blueprint, MovieModel.blueprint, MovieActorsModel.blueprint},
          test: testFetchOneHasManyThroughRelation,
        ),
        (
          label: 'fetchAll',
          models: {ActorModel.blueprint, MovieModel.blueprint, MovieActorsModel.blueprint},
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
      RelationTests.oneToOne: [
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
        (
          label: 'Unset',
          models: {CompanyModel.blueprint, CompanyAddressModel.blueprint},
          test: testUnsetHasOneRelation,
        ),
        (
          label: 'Delete (nullify)',
          models: {CompanyModel.blueprint, CompanyAddressModel.blueprint},
          test: testDeleteNullifyHasOneRelation,
        ),
        (
          label: 'Delete (cascade)',
          models: {PersonModel.blueprint, PersonPassportModel.blueprint},
          test: testDeleteCascadeHasOneRelation,
        ),
      ],
      RelationTests.oneToMany: [
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
        (
          label: 'Delete (nullify)',
          models: {ArticleModel.blueprint, ArticleTagModel.blueprint},
          test: testDeleteNullifyHasManyRelation,
        ),
        (
          label: 'Delete (cascade)',
          models: {DepartmentModel.blueprint, EmployeeModel.blueprint},
          test: testDeleteCascadeHasManyRelation,
        ),
      ],
      RelationTests.manyToOne: [
        (
          label: 'Add',
          models: {ItemModel.blueprint, ItemCategoryModel.blueprint},
          test: testAddBelongsToRelation,
        ),
        (
          label: 'Update',
          models: {ItemModel.blueprint, ItemCategoryModel.blueprint},
          test: testUpdateBelongsToRelation,
        ),
        (
          label: 'Delete',
          models: {ItemModel.blueprint, ItemCategoryModel.blueprint},
          test: testDeleteBelongsToRelation,
        ),
      ],
      RelationTests.manyToMany: [
        (
          label: 'Add',
          models: {ActorModel.blueprint, MovieModel.blueprint, MovieActorsModel.blueprint},
          test: testAddHasManyThroughRelation,
        ),
        (
          label: 'Update',
          models: {ActorModel.blueprint, MovieModel.blueprint, MovieActorsModel.blueprint},
          test: testUpdateHasManyThroughRelation,
        ),
        (
          label: 'Delete',
          models: {ActorModel.blueprint, MovieModel.blueprint, MovieActorsModel.blueprint},
          test: testDeleteHasManyThroughRelation,
        ),
      ],
    },
  );
}
