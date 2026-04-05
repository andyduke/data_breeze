// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin CompanyModel {
  static final blueprint = BreezeModelBlueprint<Company>(
    name: 'companies',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // name
      BreezeModelColumn<String>('name'),
    },

    relations: {
      BreezeModelRelation<CompanyAddress>.hasOne(
        name: 'address',
        foreignKey: BreezeRelationTypedKey('company_id', int),
      ),
    },
    builder: CompanyModel.fromRecord,
  );

  static Company fromRecord(Map<String, dynamic> map) =>
      Company(name: map[CompanyModel.name], address: map['address']);

  static const id = BreezeField('id');
  static const name = BreezeField('name');

  // ---

  Company get _self => this as Company;

  BreezeModelBlueprint get schema => CompanyModel.blueprint;

  Map<String, dynamic> toRecord() => {
    CompanyModel.name: _self.name,
    'address': _self.address,
  };
}
