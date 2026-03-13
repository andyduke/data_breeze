import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

import 'actor.dart';

part 'movie.g.dart';

@BzModel(name: 'movies')
class Movie extends BreezeModel<int> with MovieModel {
  String title;

  @BzRelationship.hasManyThrough(
    name: 'actors',
    through: 'movie_actors',
    foreignKey: 'movie_id',
    sourceKey: 'actor_id',
  )
  List<Actor> actors;

  Movie({
    required this.title,
    this.actors = const [],
  });
}
