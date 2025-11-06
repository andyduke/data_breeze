import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:test/test.dart';
import 'package:logging/logging.dart';

import 'lib/migration_models/user.dart';
import 'lib/test_utils.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.loggerName}] ${record.time} ${record.level.name}: ${record.message}');
  });

  final log = Logger('Breeze Sqlite Migration');

  group('Table changes', () {
    test('Add new table', () async {
      final store = BreezeSqliteStore(
        models: {
          MUser.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUser.blueprint.name],
        [
          [
            MUser.blueprint.name,
            MUser.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      await expectStoreTable(
        store,
        MUser.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    // TODO: Rename table

    // TODO: Delete table
  });

  // TODO: Column changes
}
