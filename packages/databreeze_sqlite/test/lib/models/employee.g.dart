// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin EmployeeModel {
  static final blueprint = BreezeModelBlueprint<Employee>(
    name: 'employees',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // name
      BreezeModelColumn<String>('name'),
    },

    builder: EmployeeModel.fromRecord,
  );

  static Employee fromRecord(Map<String, dynamic> map) =>
      Employee(name: map[EmployeeModel.name]);

  static const id = BreezeField('id');
  static const name = BreezeField('name');

  // ---

  Employee get _self => this as Employee;

  BreezeModelBlueprint get schema => EmployeeModel.blueprint;

  Map<String, dynamic> toRecord() => {EmployeeModel.name: _self.name};
}
