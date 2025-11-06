import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/migratable_model_schema.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteAddColumnMigration extends BreezeSqliteMigration {
  final BreezeSqliteMigratableModelSchema schema;
  final BreezeModelColumn column;

  BreezeSqliteAddColumnMigration(this.schema, this.column, {required super.version})
    : super(
        onBeforeMigrate: schema.onBeforeMigrate,
        onAfterMigrate: schema.onAfterMigrate,
      );

  @override
  List<String> generate() {
    final columnSql = BreezeSqliteMigration.createColumnSql(column);
    final sql = 'ALTER TABLE ${schema.name} ADD COLUMN $columnSql';
    return [sql];
  }
}
