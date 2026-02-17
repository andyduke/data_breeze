import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'deletion_info.g.dart';

/// Deletion info model
@BzModel(
  primaryKey: 'table',
  name: 'deletion_info',
  schemaHistory: [
    BzSchemaVersion(1, [
      BzSchemaChange.column('timestamp', DateTime),
    ]),
  ],
)
class DeletionInfo extends BreezeModel<String> with DeletionInfoModel {
  String table;

  DateTime timestamp;

  DeletionInfo({
    required this.table,
    required this.timestamp,
  });
}
