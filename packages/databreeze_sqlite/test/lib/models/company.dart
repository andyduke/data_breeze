import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

import 'company_address.dart';

part 'company.g.dart';

@BzModel(
  name: 'companies',
)
class Company extends BreezeModel<int> with CompanyModel {
  String name;

  @BzRelationship.hasOne(
    name: 'address',
    foreignKey: BreezeRelationTypedKey('company_id', int),
  )
  CompanyAddress? address;

  Company({
    required this.name,
    this.address,
  });
}
