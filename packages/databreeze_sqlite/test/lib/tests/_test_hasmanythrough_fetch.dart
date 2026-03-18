part of 'relations_tests.dart';

Future<void> testFetchOneHasManyThroughRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'actors',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 1,
        'name': 'Actor 1',
      },
      {
        'id': 2,
        'name': 'Actor 2',
      },
      {
        'id': 3,
        'name': 'Actor 3',
      },
    ],
  );
  await store.initCollection(
    'movies',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'title': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 10,
        'title': 'Movie 1',
      },
      {
        'id': 20,
        'title': 'Movie 2',
      },
    ],
  );
  await store.initCollection(
    'movie_actors',
    {
      'movie_id': BreezeTestStoreField(type: int),
      'actor_id': BreezeTestStoreField(type: int),
    },
    [
      {'movie_id': 10, 'actor_id': 1},
      {'movie_id': 10, 'actor_id': 2},
      {'movie_id': 20, 'actor_id': 1},
      {'movie_id': 20, 'actor_id': 3},
    ],
  );

  final query = BreezeQueryById<Movie>(10);
  final movie = await query.fetch(store);

  expect(movie, isNotNull);

  expect(movie!.id, equals(10));
  expect(movie.title, equals('Movie 1'));
  expect(movie.actors, isNotNull);
  expect(movie.actors, hasLength(2));
  expect(movie.actors[0], isA<Actor>());
  expect(movie.actors[0].name, equals('Actor 1'));
  expect(movie.actors[1], isA<Actor>());
  expect(movie.actors[1].name, equals('Actor 2'));
}

Future<void> testFetchAllHasManyThroughRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'actors',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 1,
        'name': 'Actor 1',
      },
      {
        'id': 2,
        'name': 'Actor 2',
      },
      {
        'id': 3,
        'name': 'Actor 3',
      },
    ],
  );
  await store.initCollection(
    'movies',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'title': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 10,
        'title': 'Movie 1',
      },
      {
        'id': 20,
        'title': 'Movie 2',
      },
    ],
  );
  await store.initCollection(
    'movie_actors',
    {
      'movie_id': BreezeTestStoreField(type: int),
      'actor_id': BreezeTestStoreField(type: int),
    },
    [
      {'movie_id': 10, 'actor_id': 1},
      {'movie_id': 10, 'actor_id': 2},
      {'movie_id': 20, 'actor_id': 1},
      {'movie_id': 20, 'actor_id': 3},
    ],
  );

  final query = BreezeQueryAll<Movie>();
  final movies = await query.fetch(store);

  expect(movies, hasLength(2));

  expect(movies[0].id, equals(10));
  expect(movies[0].title, equals('Movie 1'));
  expect(movies[0].actors, isNotNull);
  expect(movies[0].actors, hasLength(2));
  expect(movies[0].actors[0], isA<Actor>());
  expect(movies[0].actors[0].name, equals('Actor 1'));
  expect(movies[0].actors[1], isA<Actor>());
  expect(movies[0].actors[1].name, equals('Actor 2'));

  expect(movies[1].id, equals(20));
  expect(movies[1].title, equals('Movie 2'));
  expect(movies[1].actors, isNotNull);
  expect(movies[1].actors, hasLength(2));
  expect(movies[1].actors[0], isA<Actor>());
  expect(movies[1].actors[0].name, equals('Actor 1'));
  expect(movies[1].actors[1], isA<Actor>());
  expect(movies[1].actors[1].name, equals('Actor 3'));
}
