import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'employee.g.dart';

@BzModel(name: 'employees')
class Employee extends BreezeModel<int> with EmployeeModel {
  String name;

  Employee({
    required this.name,
  });
}
