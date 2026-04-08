// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_passport.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin PersonPassportModel {
  static final blueprint = BreezeModelBlueprint<PersonPassport>(
    name: 'person_passports',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // passportNumber
      BreezeModelColumn<String>('passport_number'),
    },

    builder: PersonPassportModel.fromRecord,
  );

  static PersonPassport fromRecord(Map<String, dynamic> map) =>
      PersonPassport(passportNumber: map[PersonPassportModel.passportNumber]);

  static const id = BreezeField('id');
  static const passportNumber = BreezeField('passport_number');

  // ---

  PersonPassport get _self => this as PersonPassport;

  BreezeModelBlueprint get schema => PersonPassportModel.blueprint;

  Map<String, dynamic> toRecord() => {
    PersonPassportModel.passportNumber: _self.passportNumber,
  };
}
