import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/migratable_model_schema.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteRenameColumnMigration extends BreezeSqliteMigration {
  final BreezeSqliteMigratableModelSchema schema;
  final BreezeModelColumn column;

  BreezeSqliteRenameColumnMigration(this.schema, this.column, {required super.version})
    : super(
        onBeforeMigrate: schema.onBeforeMigrate,
        onAfterMigrate: schema.onAfterMigrate,
      );

  @override
  List<String> generate() {
    final sql = 'ALTER TABLE ${schema.name} RENAME COLUMN ${column.prevName} TO ${column.name}';
    return [sql];
  }
}
