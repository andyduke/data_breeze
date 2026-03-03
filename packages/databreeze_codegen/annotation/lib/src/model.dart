import 'package:databreeze_annotation/src/schema_version.dart';
import 'package:meta/meta_meta.dart';

enum BzModelNameStyle {
  /// Column names in the storage are in **snake_case** style.
  snakeCase,

  /// Column names in the storage are in **camelCase** style.
  camelCase,
}

@Target({TargetKind.classType})
class BzModel {
  final String? name;
  final String? primaryKey;
  final String? constructor;
  final Type? schemaVersionClass;
  final List<BzSchemaVersion> schemaHistory;
  // TODO: Rename [nameStyle] to [columnNameStyle]
  final BzModelNameStyle nameStyle;

  const BzModel({
    this.name,
    this.primaryKey,
    this.constructor,
    this.schemaVersionClass,
    this.schemaHistory = const [],
    this.nameStyle = BzModelNameStyle.snakeCase,
  });
}

@Target({TargetKind.field})
class BzColumn {
  final String name;

  const BzColumn({
    required this.name,
  });
}

@Target({TargetKind.field, TargetKind.getter})
class BzTransient {
  const BzTransient();
}
