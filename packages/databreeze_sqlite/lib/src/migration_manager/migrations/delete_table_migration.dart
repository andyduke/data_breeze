import 'package:databreeze_sqlite/src/migration_manager/migratable_model_schema.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteDeleteTableMigration extends BreezeSqliteMigration {
  final BreezeSqliteMigratableModelSchema schema;

  BreezeSqliteDeleteTableMigration(
    this.schema, {
    required super.version,
  }) : super(
         onBeforeMigrate: schema.onBeforeMigrate,
         onAfterMigrate: schema.onAfterMigrate,
       );

  @override
  List<String> generate() {
    final sql = 'DROP TABLE ${schema.name}';
    return [sql];
  }
}
