part of 'relations_tests.dart';

Future<void> testAddHasManyRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'article_tags',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
      'article_id': BreezeTestStoreField(type: int),
    },
    [],
  );
  await store.initCollection(
    'articles',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'title': BreezeTestStoreField(type: String),
      'text': BreezeTestStoreField(type: String),
    },
    [],
  );

  final article = Article(
    title: 'Article 1',
    text: 'Article body 1',
    tags: [
      ArticleTag(name: 'tag1'),
      ArticleTag(name: 'tag2'),
    ],
  );

  await store.save(article);

  expect(article.isNew, isFalse);
  expect(article.id, isNotNull);

  expect(article.tags, hasLength(2));

  final articles = await store.fetchAllRecords(table: 'articles');
  expect(
    articles,
    equals([
      {
        'id': 1,
        'title': 'Article 1',
        'text': 'Article body 1',
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
        'article_id': 1,
      },
      {
        'id': 2,
        'name': 'tag2',
        'article_id': 1,
      },
    ]),
  );
}

Future<void> testUpdateHasManyRelation({
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
    ],
  );

  final query = BreezeQueryById<Article>(1);
  final article = await query.fetch(store);

  expect(article, isNotNull);
  expect(article!.tags, hasLength(2));
  expect(article.tags[0], isA<ArticleTag>());

  article.title = 'Article 1*';
  article.tags[1].name = 'tag2*';
  article.tags.add(ArticleTag(name: 'tag3'));
  await store.save(article);

  final articles = await store.fetchAllRecords(table: 'articles');
  expect(
    articles,
    equals([
      {
        'id': 1,
        'title': 'Article 1*',
        'text': 'Article body 1',
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
        'article_id': 1,
      },
      {
        'id': 2,
        'name': 'tag2*',
        'article_id': 1,
      },
      {
        'id': 3,
        'name': 'tag3',
        'article_id': 1,
      },
    ]),
  );
}
