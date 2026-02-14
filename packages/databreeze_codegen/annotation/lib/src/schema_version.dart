import 'package:databreeze_annotation/src/schema_change.dart';

class BzSchemaVersion {
  final int version;
  final List<BzSchemaChange> changes;

  const BzSchemaVersion(this.version, this.changes);
}
