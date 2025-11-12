import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteCreateTableMigration extends BreezeSqliteMigration {
  final BreezeBaseModelSchema schema;

  BreezeSqliteCreateTableMigration(
    this.schema, {
    required super.typeConverters,
    required super.version,
  }) : super(
         onBeforeMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onBeforeMigrate,
         onAfterMigrate: BreezeSqliteMigration.sqliteSchemaOf(schema)?.onAfterMigrate,
       );

  @override
  List<String> generate() {
    final columnsSql = <String>[];
    for (final column in schema.columns.values) {
      columnsSql.add(BreezeSqliteMigration.createColumnSql(column, typeConverters));
    }
    final options = schema.tags.contains(#temporary) ? ' TEMP' : '';

    final sql =
        '''CREATE$options TABLE ${schema.name} (
  ${columnsSql.join(',\n  ')}
)''';
    return [sql];
  }
}
