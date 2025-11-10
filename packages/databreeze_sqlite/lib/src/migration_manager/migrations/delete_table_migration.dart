import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteDeleteTableMigration extends BreezeSqliteMigration {
  final BreezeBaseModelSchema schema;

  BreezeSqliteDeleteTableMigration(
    this.schema, {
    required super.version,
  }) : super(
         onBeforeMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onBeforeMigrate,
         onAfterMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onAfterMigrate,
       );

  @override
  List<String> generate() {
    final sql = 'DROP TABLE ${schema.name}';
    return [sql];
  }
}
