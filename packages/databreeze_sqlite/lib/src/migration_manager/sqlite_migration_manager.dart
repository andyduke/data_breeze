import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/migration_manager/sqlite_migration_delegate.dart';
import 'package:sqlite_async/sqlite_async.dart';

class BreezeSqliteMigrationManager extends BreezeMigrationManager<SqliteWriteContext> {
  const BreezeSqliteMigrationManager({
    super.delegate = const BreezeSqliteMigrationDelegate(),
    super.typeConverters,
    super.log,
  });

  @override
  List<BreezeMigration> createMigrationPlan(BreezeBaseModelSchema schema) {
    final migrations = <BreezeMigration>[];
    final List<BreezeBaseModelSchema> versions = switch (schema) {
      BreezeModelVersionedSchema s => s.versions,
      BreezeModelSchema s => {s},
      _ => <BreezeBaseModelSchema>{},
    }.toList();

    for (var i = 0; i < versions.length; i++) {
      final current = versions[i];
      final version = switch (current) {
        BreezeModelSchemaVersion(version: final version) => version,
        _ => 1,
      };
      final migrationTypeConverters = {
        ...current.typeConverters,
        ...typeConverters,
      };

      // Delete table if model marked as deleted
      if (current.isDeleted) {
        migrations.add(
          delegate.deleteTableMigration(current, version: version, typeConverters: migrationTypeConverters),
        );
        continue;
      }

      // Initial table creation
      if (i == 0) {
        migrations.add(
          delegate.createTableMigration(current, version: version, typeConverters: migrationTypeConverters),
        );
        continue;
      }

      final previous = versions[i - 1];

      final prevCols = {for (var c in previous.columns.values) c.name: c};
      final currCols = {for (var c in current.columns.values) c.name: c};

      final renamedCols = current.columns.values.where((c) => c.prevName != null).toList();
      final addedCols = current.columns.values
          .where((c) => !prevCols.containsKey(c.name) && c.prevName == null)
          .toList();
      final deletedCols = previous.columns.values
          .where((c) => !currCols.containsKey(c.name) && (renamedCols.indexWhere((r) => c.name == r.prevName) == -1))
          .toList();

      final typeChanged = current.columns.values.any((c) {
        final prev = c.prevName != null ? prevCols[c.prevName!] : prevCols[c.name];
        return prev != null && prev.type != c.type;
      });

      final tableRenamed = current.prevName != null && current.prevName != current.name;

      final temporaryTagChanged =
          current.tags.difference(previous.tags).contains(#temporary) ||
          previous.tags.difference(current.tags).contains(#temporary);

      final requiresRebuild = deletedCols.isNotEmpty || typeChanged || temporaryTagChanged;

      if (requiresRebuild) {
        migrations.add(
          delegate.rebuildTableMigration(previous, current, version: version, typeConverters: migrationTypeConverters),
        );
      } else {
        if (tableRenamed) {
          migrations.add(
            delegate.renameTableMigration(current, version: version, typeConverters: migrationTypeConverters),
          );
        }

        for (final col in renamedCols) {
          migrations.add(
            delegate.renameColumnMigration(current, col, version: version, typeConverters: migrationTypeConverters),
          );
        }

        for (final col in addedCols) {
          migrations.add(
            delegate.addColumnMigration(current, col, version: version, typeConverters: migrationTypeConverters),
          );
        }
      }
    }

    return migrations;
  }
}
