// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin DepartmentModel {
  static final blueprint = BreezeModelBlueprint<Department>(
    name: 'departments',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // name
      BreezeModelColumn<String>('name'),
    },

    relations: {
      BreezeModelRelation<Employee>.hasMany(
        name: 'employees',
        foreignKey: BreezeRelationTypedKey('department_id', int),
        deleteRule: BreezeRelationshipDeleteRule.cascade,
      ),
    },
    builder: DepartmentModel.fromRecord,
  );

  static Department fromRecord(Map<String, dynamic> map) =>
      Department(name: map[DepartmentModel.name], employees: map['employees']);

  static const id = BreezeField('id');
  static const name = BreezeField('name');

  // ---

  Department get _self => this as Department;

  BreezeModelBlueprint get schema => DepartmentModel.blueprint;

  Map<String, dynamic> toRecord() => {
    DepartmentModel.name: _self.name,
    'employees': _self.employees,
  };
}
