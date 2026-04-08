import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'person_passport.g.dart';

@BzModel(name: 'person_passports')
class PersonPassport extends BreezeModel<int> with PersonPassportModel {
  String passportNumber;

  PersonPassport({
    required this.passportNumber,
  });
}
