import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'company_address.g.dart';

@BzModel(
  name: 'company_addresses',
)
class CompanyAddress extends BreezeModel<int> with CompanyAddressModel {
  String location;
  // int? companyId;

  CompanyAddress({
    required this.location,
    // this.companyId,
  });
}
