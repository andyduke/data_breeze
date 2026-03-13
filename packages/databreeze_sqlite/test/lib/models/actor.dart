import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'actor.g.dart';

@BzModel(name: 'actors')
class Actor extends BreezeModel<int> with ActorModel {
  String name;

  Actor({
    required this.name,
  });
}
