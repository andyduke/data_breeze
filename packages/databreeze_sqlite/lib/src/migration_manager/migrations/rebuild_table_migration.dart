import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration.dart';

class BreezeSqliteRebuildTableMigration extends BreezeSqliteMigration {
  final BreezeBaseModelSchema from;
  final BreezeBaseModelSchema to;

  BreezeSqliteRebuildTableMigration(
    this.from,
    this.to, {
    required super.typeConverters,
    required super.version,
  }) : super(
         onBeforeMigrate: BreezeSqliteMigration.sqliteSchemaOf(to)?.onBeforeMigrate,
         onAfterMigrate: BreezeSqliteMigration.sqliteSchemaOf(to)?.onAfterMigrate,
       );

  @override
  List<String> generate() {
    final sql = <String>[];

    final oldName = from.prevName ?? from.name;
    final newName = to.name;
    final tempName = '${newName}_temp_v$version';

    final options = to.tags.contains(#temporary) ? ' TEMP' : '';

    // Create temp table
    final newColumnsSql = <String>[];
    for (final column in to.columns.values) {
      newColumnsSql.add(BreezeSqliteMigration.createColumnSql(column, typeConverters));
    }
    sql.add('''CREATE$options TABLE $tempName (
  ${newColumnsSql.join(',\n  ')}
)''');

    // Diff columns
    final commonColumns = from.columns.values
        .where((c) => to.columns.values.any((n) => n.name == c.name || n.prevName == c.name))
        .map((c) => c.name)
        .toList();

    // final newColumns = to.columns.map((c) => c.prevName ?? c.name).toList();

    final copyCols = <String>[];
    for (final col in to.columns.values) {
      final source = col.prevName ?? col.name;
      if (commonColumns.contains(source)) {
        copyCols.add(source);
      } else {
        copyCols.add('NULL AS ${col.name}');
      }
    }

    // Copy data from old table to temp table
    sql.add(
      'INSERT INTO $tempName (${to.columns.values.map((c) => c.name).join(', ')}) '
      'SELECT ${copyCols.join(', ')} FROM $oldName',
    );

    // Remove old table
    sql.add('DROP TABLE $oldName');

    // Rename temp table to new name
    sql.add('ALTER TABLE $tempName RENAME TO $newName');

    return sql;
  }
}
