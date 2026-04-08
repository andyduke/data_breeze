// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin PersonModel {
  static final blueprint = BreezeModelBlueprint<Person>(
    name: 'persons',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // name
      BreezeModelColumn<String>('name'),
    },

    relations: {
      BreezeModelRelation<PersonPassport>.hasOne(
        name: 'passport',
        foreignKey: BreezeRelationTypedKey('person_id', int),
        deleteRule: BreezeRelationshipDeleteRule.cascade,
      ),
    },
    builder: PersonModel.fromRecord,
  );

  static Person fromRecord(Map<String, dynamic> map) =>
      Person(name: map[PersonModel.name], passport: map['passport']);

  static const id = BreezeField('id');
  static const name = BreezeField('name');

  // ---

  Person get _self => this as Person;

  BreezeModelBlueprint get schema => PersonModel.blueprint;

  Map<String, dynamic> toRecord() => {
    PersonModel.name: _self.name,
    'passport': _self.passport,
  };
}
