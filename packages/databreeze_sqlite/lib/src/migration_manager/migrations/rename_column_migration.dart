import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteRenameColumnMigration extends BreezeSqliteMigration {
  final BreezeBaseModelSchema schema;
  final BreezeModelColumn column;

  BreezeSqliteRenameColumnMigration(
    this.schema,
    this.column, {
    required super.typeConverters,
    required super.version,
  }) : super(
         onBeforeMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onBeforeMigrate,
         onAfterMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onAfterMigrate,
       );

  @override
  List<String> generate() {
    final sql = 'ALTER TABLE ${schema.name} RENAME COLUMN ${column.prevName} TO ${column.name}';
    return [sql];
  }
}
