import 'package:databreeze_annotation/src/schema_version.dart';
import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
class BzModel {
  final String? name;
  final String? primaryKey;
  final Type? schemaVersionClass;
  final List<BzSchemaVersion> schemaHistory;

  const BzModel({
    this.name,
    this.primaryKey,
    this.schemaVersionClass,
    this.schemaHistory = const [],
  });
}

@Target({TargetKind.field})
class BzColumn {
  final String name;

  const BzColumn({
    required this.name,
  });
}

@Target({TargetKind.field})
class BzTransient {
  const BzTransient();
}
