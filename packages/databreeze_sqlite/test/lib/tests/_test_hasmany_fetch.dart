part of 'relations_tests.dart';

Future<void> testFetchOneHasManyRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'article_tags',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
      'article_id': BreezeTestStoreField(type: int),
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
        'text': 'Body 1',
      },
      {
        'id': 2,
        'title': 'Article 2',
        'text': 'Body 2',
      },
    ],
  );

  final query = BreezeQueryById<Article>(1);
  final article = await query.fetch(store);

  expect(article, isNotNull);
  expect(article!.id, equals(1));
  expect(article.title, equals('Article 1'));
  expect(article.tags, hasLength(2));
}
