import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteAddColumnMigration extends BreezeSqliteMigration {
  final BreezeBaseModelSchema schema;
  final BreezeModelColumn column;

  BreezeSqliteAddColumnMigration(
    this.schema,
    this.column, {
    required super.version,
  }) : super(
         onBeforeMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onBeforeMigrate,
         onAfterMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onAfterMigrate,
       );

  @override
  List<String> generate() {
    final columnSql = BreezeSqliteMigration.createColumnSql(column);
    final sql = 'ALTER TABLE ${schema.name} ADD COLUMN $columnSql';
    return [sql];
  }
}
