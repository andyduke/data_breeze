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
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUser.blueprint,
        },
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
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Rename table', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserRenamed.blueprint,
        },
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
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Delete table', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserDeleted.blueprint,
        },
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
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserAddColumn.blueprint,
        },
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
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'age', type: 'INTEGER', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Delete column', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserDeleteColumn.blueprint,
        },
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
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Rename column', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserRenameColumn.blueprint,
        },
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
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Change column type', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserChangeColumnType.blueprint,
        },
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
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'code', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Rename column and add new column', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserRenameOneAndAddAnotherColumn.blueprint,
        },
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
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'firstName', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'lastName', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });
  });

  group('Hooks (beforeMigrate, afterMigrate)', () {
    test('Add new table', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserWithHooks.blueprint,
        },
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
        [MUserWithHooks.blueprint.name],
        [
          [
            MUserWithHooks.blueprint.name,
            MUserWithHooks.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserWithHooks.blueprint.name,
        [
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );

      // Make sure that both handlers (before and after) have been executed.
      final res = await db.execute('PRAGMA user_version');
      final row = res.rows.firstOrNull;
      expect(row, equals([2]));
    });

    test('Rename table', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserRenamedWithHooks.blueprint,
        },
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
        [MUserRenamedWithHooks.blueprint.name],
        [
          [
            MUserRenamedWithHooks.blueprint.name,
            MUserRenamedWithHooks.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserRenamedWithHooks.blueprint.name,
        [
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );

      // Make sure that both handlers (before and after) have been executed.
      final res = await db.execute('PRAGMA user_version');
      final row = res.rows.firstOrNull;
      expect(row, equals([2]));
    });

    test('Delete table', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserDeletedWithHooks.blueprint,
        },
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
        [MUserDeletedWithHooks.blueprint.name],
        [],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserDeletedWithHooks.blueprint.name,
        [],
        log: log,
      );

      // Make sure that both handlers (before and after) have been executed.
      final res = await db.execute('PRAGMA user_version');
      final row = res.rows.firstOrNull;
      expect(row, equals([2]));
    });

    test('Add new column', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserAddColumnWithHooks.blueprint,
        },
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
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'age', type: 'INTEGER', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );

      // Make sure that both handlers (before and after) have been executed.
      final res = await db.execute('PRAGMA user_version');
      final row = res.rows.firstOrNull;
      expect(row, equals([2]));
    });

    test('Delete column', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserDeleteColumnWithHooks.blueprint,
        },
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
        [MUserDeleteColumnWithHooks.blueprint.name],
        [
          [
            MUserDeleteColumnWithHooks.blueprint.name,
            MUserDeleteColumnWithHooks.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserDeleteColumnWithHooks.blueprint.name,
        [
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );

      // Make sure that both handlers (before and after) have been executed.
      final res = await db.execute('PRAGMA user_version');
      final row = res.rows.firstOrNull;
      expect(row, equals([2]));
    });

    test('Rename column', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserRenameColumnWithHooks.blueprint,
        },
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
        [MUserRenameColumnWithHooks.blueprint.name],
        [
          [
            MUserRenameColumnWithHooks.blueprint.name,
            MUserRenameColumnWithHooks.blueprint.latestVersion.version,
          ],
        ],
        log: log,
      );

      // Ensure that the table structure in the database matches the schema.
      await expectStoreTable(
        store,
        MUserRenameColumnWithHooks.blueprint.name,
        [
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );

      // Make sure that both handlers (before and after) have been executed.
      final res = await db.execute('PRAGMA user_version');
      final row = res.rows.firstOrNull;
      expect(row, equals([2]));
    });
  });

  group('Schema tag', () {
    test('Temporary tag + Add new column', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MUserAddColumn.blueprint,
          MProgressTemp.blueprint,
        },
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
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'age', type: 'INTEGER', notNull: true, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
      await expectStoreTable(
        store,
        MProgressTemp.blueprint.name,
        [
          (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
          (name: 'progress', type: 'REAL', notNull: true, defaultValue: null, primaryKey: false),
          (name: 'error', type: 'TEXT', notNull: false, defaultValue: null, primaryKey: false),
        ],
        log: log,
      );
    });

    test('Temporary tag + Delete column (rebuild table)', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MProgressTempDeleteColumn.blueprint,
        },
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
      final store = BreezeSqliteStore.inMemory(
        models: {
          MProgressAddTemporaryTag.blueprint,
        },
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
      final store = BreezeSqliteStore.inMemory(
        models: {
          MProgressRemoveTemporaryTag.blueprint,
        },
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
