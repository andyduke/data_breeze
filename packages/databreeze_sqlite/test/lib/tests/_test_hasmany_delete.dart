part of 'relations_tests.dart';

Future<void> testDeleteNullifyHasManyRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'article_tags',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
      'article_id': BreezeTestStoreField(type: int, isNullable: true),
    },
    [
      {
        'id': 1,
        'name': 'tag1',
        'article_id': 1,
      },
      {
        'id': 2,
        'name': 'tag2',
        'article_id': 1,
      },
      {
        'id': 3,
        'name': 'tag3',
        'article_id': 2,
      },
    ],
  );
  await store.initCollection(
    'articles',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'title': BreezeTestStoreField(type: String),
      'text': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 1,
        'title': 'Article 1',
        'text': 'Article body 1',
      },
      {
        'id': 2,
        'title': 'Article 2',
        'text': 'Article body 2',
      },
    ],
  );

  final query = BreezeQueryById<Article>(1);
  final article = await query.fetch(store);

  expect(article, isNotNull);
  expect(article!.tags, hasLength(2));
  expect(article.tags[0], isA<ArticleTag>());

  await store.delete(article);

  final articles = await store.fetchAllRecords(table: 'articles');
  expect(
    articles,
    equals([
      {
        'id': 2,
        'title': 'Article 2',
        'text': 'Article body 2',
      },
    ]),
  );

  final articleTags = await store.fetchAllRecords(table: 'article_tags');
  expect(
    articleTags,
    equals([
      {
        'id': 1,
        'name': 'tag1',
        'article_id': null,
      },
      {
        'id': 2,
        'name': 'tag2',
        'article_id': null,
      },
      {
        'id': 3,
        'name': 'tag3',
        'article_id': 2,
      },
    ]),
  );
}

Future<void> testDeleteCascadeHasManyRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'employees',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
      'department_id': BreezeTestStoreField(type: int, isNullable: true),
    },
    [
      {
        'id': 1,
        'name': 'Employee 1',
        'department_id': 1,
      },
      {
        'id': 2,
        'name': 'Employee 2',
        'department_id': 1,
      },
      {
        'id': 3,
        'name': 'Employee 3',
        'department_id': 2,
      },
    ],
  );
  await store.initCollection(
    'departments',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 1,
        'name': 'Department 1',
      },
      {
        'id': 2,
        'name': 'Department 2',
      },
    ],
  );

  final query = BreezeQueryById<Department>(1);
  final department = await query.fetch(store);

  expect(department, isNotNull);
  expect(department!.employees, hasLength(2));
  expect(department.employees[0], isA<Employee>());

  await store.delete(department);

  final departments = await store.fetchAllRecords(table: 'departments');
  expect(
    departments,
    equals([
      {
        'id': 2,
        'name': 'Department 2',
      },
    ]),
  );

  final employees = await store.fetchAllRecords(table: 'employees');
  expect(
    employees,
    equals([
      {
        'id': 3,
        'name': 'Employee 3',
        'department_id': 2,
      },
    ]),
  );
}
