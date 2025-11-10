import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteRenameTableMigration extends BreezeSqliteMigration {
  final BreezeBaseModelSchema schema;

  BreezeSqliteRenameTableMigration(
    this.schema, {
    required super.version,
  }) : super(
         onBeforeMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onBeforeMigrate,
         onAfterMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onAfterMigrate,
       );

  @override
  List<String> generate() {
    final sql = 'ALTER TABLE ${schema.prevName} RENAME TO ${schema.name}';
    return [sql];
  }
}
