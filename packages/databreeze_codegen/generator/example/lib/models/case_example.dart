import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'case_example.g.dart';

/// Case example model
@BzModel(
  name: 'caseExample',
  nameStyle: BzModelNameStyle.camelCase,
  schemaHistory: [
    BzSchemaVersion(1, [
      BzSchemaChange.column('title', String),
      BzSchemaChange.column('noteText', String, isNullable: true),
    ]),
  ],
)
class CaseExample extends BreezeModel<int> with CaseExampleModel {
  String title;

  String? noteText;

  CaseExample({
    required this.title,
    required this.noteText,
  });
}
