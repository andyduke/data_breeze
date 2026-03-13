// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin MovieModel {
  static final blueprint = BreezeModelBlueprint<Movie>(
    name: 'movies',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // title
      BreezeModelColumn<String>('title'),
    },

    relations: {
      BreezeModelRelation<Actor>.hasManyThrough(
        name: 'actors',
        foreignKey: 'movie_id',
        sourceKey: 'actor_id',
        through: 'movie_actors',
      ),
    },
    builder: MovieModel.fromRecord,
  );

  static Movie fromRecord(Map<String, dynamic> map) =>
      Movie(title: map[MovieModel.title], actors: map['actors']);

  static const id = BreezeField('id');
  static const title = BreezeField('title');

  // ---

  Movie get _self => this as Movie;

  BreezeModelBlueprint get schema => MovieModel.blueprint;

  Map<String, dynamic> toRecord() => {
    MovieModel.title: _self.title,
    'actors': _self.actors,
  };
}
