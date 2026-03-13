// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin ActorModel {
  static final blueprint = BreezeModelBlueprint<Actor>(
    name: 'actors',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // name
      BreezeModelColumn<String>('name'),
    },

    builder: ActorModel.fromRecord,
  );

  static Actor fromRecord(Map<String, dynamic> map) =>
      Actor(name: map[ActorModel.name]);

  static const id = BreezeField('id');
  static const name = BreezeField('name');

  // ---

  Actor get _self => this as Actor;

  BreezeModelBlueprint get schema => ActorModel.blueprint;

  Map<String, dynamic> toRecord() => {ActorModel.name: _self.name};
}
