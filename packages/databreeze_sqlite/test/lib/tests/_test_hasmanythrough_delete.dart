part of 'relations_tests.dart';

Future<void> testDeleteHasManyThroughRelation({
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
        'id': 1,
        'title': 'Movie 1',
      },
      {
        'id': 2,
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
      {'movie_id': 1, 'actor_id': 1},
      {'movie_id': 1, 'actor_id': 2},
      {'movie_id': 2, 'actor_id': 2},
      {'movie_id': 2, 'actor_id': 3},
    ],
  );

  final query = BreezeQueryById<Movie>(1);
  final movie = await query.fetch(store);

  expect(movie, isNotNull);
  expect(movie!.actors, hasLength(2));
  expect(movie.actors[0], isA<Actor>());

  await store.delete(movie);

  final movies = await store.fetchAllRecords(table: 'movies');
  expect(
    movies,
    equals([
      {
        'id': 2,
        'title': 'Movie 2',
      },
    ]),
  );

  final actors = await store.fetchAllRecords(table: 'actors');
  expect(
    actors,
    equals([
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
    ]),
  );

  final movieActors = await store.fetchAllRecords(table: 'movie_actors');
  expect(
    movieActors,
    equals([
      {'movie_id': 2, 'actor_id': 2},
      {'movie_id': 2, 'actor_id': 3},
    ]),
  );
}
