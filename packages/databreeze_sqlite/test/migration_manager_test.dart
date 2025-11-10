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

      // Ensure that the table schema version in the database is correct.
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

      // Ensure that the table structure in the database matches the schema.
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

    test('Rename table', () async {
      final store = BreezeSqliteStore(
        models: {
          MUserRenamed.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table schema version in the database is correct.
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUserRenamed.blueprint.name],
        [
          [
            MUserRenamed.blueprint.name,
            MUserRenamed.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserRenamed.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Delete table', () async {
      final store = BreezeSqliteStore(
        models: {
          MUserDeleted.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table schema version in the database is correct.
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUserDeleted.blueprint.name],
        [],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserDeleted.blueprint.name,
        [],
        log: log,
      );
    });
  });

  group('Column changes', () {
    test('Add new column', () async {
      final store = BreezeSqliteStore(
        models: {
          MUserAddColumn.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table schema version in the database is correct.
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUserAddColumn.blueprint.name],
        [
          [
            MUserAddColumn.blueprint.name,
            MUserAddColumn.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserAddColumn.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'age', type: 'INT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Delete column', () async {
      final store = BreezeSqliteStore(
        models: {
          MUserDeleteColumn.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table schema version in the database is correct.
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUserDeleteColumn.blueprint.name],
        [
          [
            MUserDeleteColumn.blueprint.name,
            MUserDeleteColumn.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserDeleteColumn.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Rename column', () async {
      final store = BreezeSqliteStore(
        models: {
          MUserRenameColumn.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table schema version in the database is correct.
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUserRenameColumn.blueprint.name],
        [
          [
            MUserRenameColumn.blueprint.name,
            MUserRenameColumn.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserRenameColumn.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Change column type', () async {
      final store = BreezeSqliteStore(
        models: {
          MUserChangeColumnType.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table schema version in the database is correct.
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUserChangeColumnType.blueprint.name],
        [
          [
            MUserChangeColumnType.blueprint.name,
            MUserChangeColumnType.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserChangeColumnType.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'code', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Rename column and add new column', () async {
      final store = BreezeSqliteStore(
        models: {
          MUserRenameOneAndAddAnotherColumn.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table schema version in the database is correct.
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUserRenameOneAndAddAnotherColumn.blueprint.name],
        [
          [
            MUserRenameOneAndAddAnotherColumn.blueprint.name,
            MUserRenameOneAndAddAnotherColumn.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserRenameOneAndAddAnotherColumn.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'firstName', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'lastName', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });
  });

  group('Hooks (beforeMigrate, afterMigrate)', () {
    // TODO: Add new table

    // TODO: Rename table

    // TODO: Delete table

    // TODO: Rebuild table

    test('Add new column', () async {
      final store = BreezeSqliteStore(
        models: {
          MUserAddColumnWithHooks.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      final db = await store.database;

      // Ensure that the table schema version in the database is correct.
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUserAddColumnWithHooks.blueprint.name],
        [
          [
            MUserAddColumnWithHooks.blueprint.name,
            MUserAddColumnWithHooks.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserAddColumnWithHooks.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'age', type: 'INT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );

      final res = await db.execute('PRAGMA user_version');
      final row = res.rows.firstOrNull;
      expect(row, equals([2]));
    });

    // TODO: Rename column
  });

  group('Schema tag', () {
    test('Temporary tag + Add new column', () async {
      final store = BreezeSqliteStore(
        models: {
          MUserAddColumn.blueprint,
          MProgressTemp.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table schema version in the database is correct.
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MUserAddColumn.blueprint.name],
        [
          [
            MUserAddColumn.blueprint.name,
            MUserAddColumn.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );
      await expectStoreTableRows(
        store,
        'SELECT * FROM ${BreezeSqliteMigrationDelegate.migrationsTableName} WHERE table_name = ?',
        [MProgressTemp.blueprint.name],
        [
          [
            MProgressTemp.blueprint.name,
            MProgressTemp.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserAddColumn.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'age', type: 'INT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
      await expectStoreTable(
        store,
        MProgressTemp.blueprint.name,
        [
          (name: 'id', type: 'INT', notNull: true, defaultValue: null, primaryKey: true),
          (name: 'progress', type: 'REAL', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'error', type: 'TEXT', notNull: false, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Temporary tag + Delete column (rebuild table)', () async {
      final store = BreezeSqliteStore(
        models: {
          MProgressTempDeleteColumn.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table in the database is a temporary table.
      await expectStoreTableRows(
        store,
        'SELECT name FROM sqlite_temp_master WHERE type = \'table\'',
        [],
        [
          [
            MProgressTempDeleteColumn.blueprint.name,
          ],
        ],
        log: log,
      );
    });

    test('Add temporary tag', () async {
      final store = BreezeSqliteStore(
        models: {
          MProgressAddTemporaryTag.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the table in the database is a temporary table.
      await expectStoreTableRows(
        store,
        'SELECT name FROM sqlite_temp_master WHERE type = \'table\'',
        [],
        [
          [
            MProgressAddTemporaryTag.blueprint.name,
          ],
        ],
        log: log,
      );
    });

    test('Remove temporary tag', () async {
      final store = BreezeSqliteStore(
        models: {
          MProgressRemoveTemporaryTag.blueprint,
        },
        onPath: () async => null,
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Make sure that the table in the database is no longer temporary.
      await expectStoreTableRows(
        store,
        'SELECT name FROM sqlite_temp_master WHERE type = \'table\'',
        [],
        [],
        log: log,
      );
      await expectStoreTableRows(
        store,
        'SELECT name FROM sqlite_master WHERE (type = \'table\') AND (name = ?)',
        [MProgressRemoveTemporaryTag.blueprint.name],
        [
          [
            MProgressRemoveTemporaryTag.blueprint.name,
          ],
        ],
        log: log,
      );
    });
  });
}
