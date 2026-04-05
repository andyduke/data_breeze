import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

import 'actor.dart';

part 'movie.g.dart';

@BzModel(name: 'movies')
class Movie extends BreezeModel<int> with MovieModel {
  String title;

  @BzRelationship.hasManyThrough(
    // TODO: remove name - get it from property name
    name: 'actors',
    // junction: 'movie_actors',
    // Use a model because it allows you to specify schema versions.
    junction: MovieActors,
    // TODO: ??? junction: BreezeModelBlueprint(name: 'movie_actors', columns: {BreezeModelColumn<int>('movie_id'), BreezeModelColumn<int>('actor_id')})
    // TODO: ??? How to define versions??? junction: BreezeJunction('movie_actors', 'movie_id', 'actor_id') -> extends BreezeModelBlueprint
    foreignKey: BreezeRelationKey<int>('movie_id'),
    // foreignKey: .key<int>('movie_id'),
    sourceKey: BreezeRelationKey<int>('actor_id'),
  )
  List<Actor> actors;

  Movie({
    required this.title,
    this.actors = const [],
  });
}

// TODO: @BzModel(name: 'movie_actors')
class MovieActors extends BreezeBaseModel with MovieActorsModel {
  int movieId;

  int actorId;

  MovieActors({
    required this.movieId,
    required this.actorId,
  });
}

mixin MovieActorsModel {
  static final blueprint = BreezeModelBlueprint<MovieActors>(
    name: 'movie_actors',
    columns: {
      // movie_id
      BreezeModelColumn<int>('movie_id'),

      // actor_id
      BreezeModelColumn<int>('actor_id'),
    },
    builder: MovieActorsModel.fromRecord,
  );

  static MovieActors fromRecord(Map<String, dynamic> map) =>
      MovieActors(movieId: map[MovieActorsModel.movieId], actorId: map[MovieActorsModel.actorId]);

  static const movieId = BreezeField('movie_id');
  static const actorId = BreezeField('actor_id');

  // ---

  MovieActors get _self => this as MovieActors;

  BreezeModelBlueprint get schema => MovieActorsModel.blueprint;

  Map<String, dynamic> toRecord() => {
    MovieActorsModel.movieId: _self.movieId,
    MovieActorsModel.actorId: _self.actorId,
  };
}
