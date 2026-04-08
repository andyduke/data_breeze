import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

import 'person_passport.dart';

part 'person.g.dart';

@BzModel(name: 'persons')
class Person extends BreezeModel<int> with PersonModel {
  String name;

  @BzRelationship.hasOne(
    name: 'passport',
    foreignKey: BreezeRelationTypedKey('person_id', int),
    deleteRule: BreezeRelationshipDeleteRule.cascade,
  )
  PersonPassport? passport;

  Person({
    required this.name,
    this.passport,
  });
}
