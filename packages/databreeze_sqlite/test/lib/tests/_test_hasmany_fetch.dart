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

  expect(article.tags[0], isA<ArticleTag>());
  expect(article.tags[0].name, equals('tag1'));

  expect(article.tags[1], isA<ArticleTag>());
  expect(article.tags[1].name, equals('tag2'));
}

Future<void> testFetchAllHasManyRelation({
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

  final query = BreezeQueryAll<Article>();
  final articles = await query.fetch(store);

  expect(articles, hasLength(2));

  expect(articles[0].id, equals(1));
  expect(articles[0].title, equals('Article 1'));
  expect(articles[0].tags, hasLength(2));
  expect(articles[0].tags[0], isA<ArticleTag>());
  expect(articles[0].tags[0].name, equals('tag1'));
  expect(articles[0].tags[1], isA<ArticleTag>());
  expect(articles[0].tags[1].name, equals('tag2'));

  expect(articles[1].id, equals(2));
  expect(articles[1].title, equals('Article 2'));
  expect(articles[1].tags, hasLength(1));
  expect(articles[1].tags[0], isA<ArticleTag>());
  expect(articles[1].tags[0].name, equals('tag3'));
}
