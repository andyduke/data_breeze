import 'package:databreeze_sqlite/src/migration_manager/migratable_model_schema.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteCreateTableMigration extends BreezeSqliteMigration {
  final BreezeSqliteMigratableModelSchema schema;

  BreezeSqliteCreateTableMigration(
    this.schema, {
    required super.version,
  }) : super(
         onBeforeMigrate: schema.onBeforeMigrate,
         onAfterMigrate: schema.onAfterMigrate,
       );

  @override
  List<String> generate() {
    final columnsSql = <String>[];
    for (final column in schema.columns.values) {
      columnsSql.add(BreezeSqliteMigration.createColumnSql(column));
    }
    final options = (schema.tag == #temporary) ? ' TEMP' : '';

    final sql =
        '''CREATE$options TABLE ${schema.name} (
  ${columnsSql.join(',\n  ')}
)''';
    return [sql];
  }
}
