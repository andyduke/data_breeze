import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

import 'employee.dart';

part 'department.g.dart';

@BzModel(name: 'departments')
class Department extends BreezeModel<int> with DepartmentModel {
  String name;

  @BzRelationship.hasMany(
    name: 'employees',
    foreignKey: BreezeRelationTypedKey('department_id', int),
    deleteRule: BreezeRelationshipDeleteRule.cascade,
  )
  List<Employee> employees;

  Department({
    required this.name,
    this.employees = const [],
  });
}
