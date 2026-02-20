import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'deletion_info.g.dart';

/// Deletion info model
@BzModel(
  primaryKey: 'table',
  name: 'deletion_info',
  constructor: '_',
  schemaHistory: [
    BzSchemaVersion(1, [
      // BzSchemaChange.column('table', String),
      BzSchemaChange.column('timestamp', DateTime),
    ]),
  ],
)
class DeletionInfo extends BreezeModel<String> with DeletionInfoModel {
  String? get table => id;
  // set table(String value) => id = value;

  DateTime timestamp;

  DeletionInfo({
    required String table,
    required this.timestamp,
  }) {
    id = table;
  }

  DeletionInfo._({
    required this.timestamp,
  });
}
