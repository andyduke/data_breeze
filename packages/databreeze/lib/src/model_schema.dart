import 'package:collection/collection.dart';
import 'package:databreeze/src/model_column.dart';

abstract interface class BreezeBaseModelSchema {
  /// The name of the table in the database
  abstract final String name;

  /// The previous name of the table in the database
  ///
  /// Used in a versioned schema when renaming a table.
  abstract final String? prevName;

  /// The name of the key field in the table
  abstract final String? key;

  /// List of column definitions in the model schema
  abstract final Map<String, BreezeModelColumn> columns;

  /// A flag indicating whether the model has been
  /// removed in this version of the schema?
  abstract final bool isDeleted;

  /// Allows you to pass parameters to the migration
  ///
  /// For example, for SQLite you can specify the `#temporary`
  /// symbol to create a temporary table.
  abstract final Set<Object?> tags;

  const BreezeBaseModelSchema();
}

class BreezeModelSchema implements BreezeBaseModelSchema {
  @override
  final String name;

  @override
  final String? prevName;

  @override
  final String? key;

  @override
  final Map<String, BreezeModelColumn> columns;

  @override
  final bool isDeleted;

  @override
  final Set<Object?> tags;

  BreezeModelSchema({
    required this.name,
    this.prevName,
    required Set<BreezeModelColumn> columns,
    this.isDeleted = false,
    this.tags = const {},
  }) : columns = UnmodifiableMapView(
         {for (var column in columns) column.name: column},
       ),
       key = columns.firstWhereOrNull((c) => c.isPrimaryKey)?.name;

  @override
  bool operator ==(covariant BreezeModelSchemaVersion other) => (name == other.name);

  @override
  int get hashCode => name.hashCode;
}

class BreezeModelSchemaVersion extends BreezeModelSchema {
  final int version;

  BreezeModelSchemaVersion({
    this.version = 1,
    required super.name,
    super.prevName,
    required super.columns,
    super.tags,
  });

  BreezeModelSchemaVersion.deleted({
    required this.version,
    required super.name,
    super.tags,
  }) : super(
         isDeleted: true,
         columns: const {},
       );

  @override
  bool operator ==(covariant BreezeModelSchemaVersion other) => (name == other.name) && (version == other.version);

  @override
  int get hashCode => Object.hash(name, version);
}

class BreezeModelVersionedSchema implements BreezeBaseModelSchema {
  final Set<BreezeModelSchemaVersion> versions;

  BreezeModelVersionedSchema(Set<BreezeModelSchemaVersion> versions)
    : assert(versions.isNotEmpty, 'You must specify at least one version of the model schema.'),
      versions = (versions.length == 1) ? {versions.first} : Set.from(versions.toList().sortedBy((e) => e.version));

  BreezeModelSchemaVersion get latestVersion => versions.last;

  @override
  String get name => latestVersion.name;

  @override
  String? get prevName => latestVersion.prevName;

  @override
  String? get key => latestVersion.key;

  @override
  Map<String, BreezeModelColumn> get columns => latestVersion.columns;

  @override
  bool get isDeleted => latestVersion.isDeleted;

  @override
  Set<Object?> get tags => latestVersion.tags;
}
