// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_address.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin CompanyAddressModel {
  static final blueprint = BreezeModelBlueprint<CompanyAddress>(
    name: 'company_addresses',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // location
      BreezeModelColumn<String>('location'),
    },

    builder: CompanyAddressModel.fromRecord,
  );

  static CompanyAddress fromRecord(Map<String, dynamic> map) =>
      CompanyAddress(location: map[CompanyAddressModel.location]);

  static const id = BreezeField('id');
  static const location = BreezeField('location');

  // ---

  CompanyAddress get _self => this as CompanyAddress;

  BreezeModelBlueprint get schema => CompanyAddressModel.blueprint;

  Map<String, dynamic> toRecord() => {
    CompanyAddressModel.location: _self.location,
  };
}
