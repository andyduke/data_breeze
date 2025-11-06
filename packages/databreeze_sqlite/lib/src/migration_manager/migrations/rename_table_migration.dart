import 'package:databreeze_sqlite/src/migration_manager/migratable_model_schema.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteRenameTableMigration extends BreezeSqliteMigration {
  final BreezeSqliteMigratableModelSchema schema;

  BreezeSqliteRenameTableMigration(
    this.schema, {
    required super.version,
  }) : super(
         onBeforeMigrate: schema.onBeforeMigrate,
         onAfterMigrate: schema.onAfterMigrate,
       );

  @override
  List<String> generate() {
    final sql = 'ALTER TABLE ${schema.prevName} RENAME TO ${schema.name}';
    return [sql];
  }
}
