import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:logging/logging.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:test/test.dart';

import 'lib/models/actor.dart';
import 'lib/models/article.dart';
import 'lib/models/article_tag.dart';
import 'lib/models/company.dart';
import 'lib/models/company_address.dart';
import 'lib/models/item.dart';
import 'lib/models/item_category.dart';
import 'lib/models/movie.dart';
import 'lib/test_store.dart';
import 'lib/test_utils.dart';
import 'lib/tests/relations_tests.dart';

final itemsMigration = SqliteMigrations()
  ..add(
    SqliteMigration(
      1,
      (tx) async {
        await tx.execute(r'''
CREATE TABLE item_categories(
    id INTEGER PRIMARY KEY,
    name TEXT
)
''');
        await tx.execute(r'''
CREATE TABLE items(
    id INTEGER PRIMARY KEY,
    name TEXT,
    category_id INT NULL
)
''');

        await tx.executeBatch(
          r'''
          INSERT INTO item_categories(id, name) VALUES(?, ?)
          ''',
          [
            [1, 'Category 1'],
            [2, 'Category 2'],
          ],
        );

        await tx.executeBatch(
          r'''
          INSERT INTO items(id, name, category_id) VALUES(?, ?, ?)
          ''',
          [
            [1, 'Item 1', 1],
            [2, 'Item 2', 1],
            [3, 'Item 3', 2],
          ],
        );
      },
    ),
  );

final articlesMigration = SqliteMigrations()
  ..add(
    SqliteMigration(
      1,
      (tx) async {
        await tx.execute(r'''
CREATE TABLE article_tags(
    id INTEGER PRIMARY KEY,
    name TEXT,
    article_id INT NULL
)
''');
        await tx.execute(r'''
CREATE TABLE articles(
    id INTEGER PRIMARY KEY,
    title TEXT,
    text TEXT
)
''');

        await tx.executeBatch(
          r'''
          INSERT INTO articles(id, title, text) VALUES(?, ?, ?)
          ''',
          [
            [1, 'Article 1', 'Body 1'],
            [2, 'Article 2', 'Body 2'],
          ],
        );

        await tx.executeBatch(
          r'''
          INSERT INTO article_tags(id, name, article_id) VALUES(?, ?, ?)
          ''',
          [
            [1, 'tag1', 1],
            [2, 'tag2', 1],
            [3, 'tag3', 2],
          ],
        );
      },
    ),
  );

final manyToManyMigration = SqliteMigrations()
  ..add(
    SqliteMigration(
      1,
      (tx) async {
        await tx.execute(r'''
CREATE TABLE actors(
    id INTEGER PRIMARY KEY,
    name TEXT
)
''');
        await tx.execute(r'''
CREATE TABLE movies(
    id INTEGER PRIMARY KEY,
    title TEXT
)
''');
        await tx.execute(r'''
CREATE TABLE movie_actors(
    movie_id INTEGER,
    actor_id INTEGER
)
''');

        await tx.executeBatch(
          r'''
          INSERT INTO actors(id, name) VALUES(?, ?)
          ''',
          [
            [1, 'Actor 1'],
            [2, 'Actor 2'],
            [3, 'Actor 3'],
          ],
        );

        await tx.executeBatch(
          r'''
          INSERT INTO movies(id, title) VALUES(?, ?)
          ''',
          [
            [10, 'Movie 1'],
            [20, 'Movie 2'],
          ],
        );

        await tx.executeBatch(
          r'''
          INSERT INTO movie_actors(movie_id, actor_id) VALUES(?, ?)
          ''',
          [
            [10, 1],
            [10, 2],
            [20, 1],
            [20, 3],
          ],
        );
      },
    ),
  );

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.loggerName}] ${record.time} ${record.level.name}: ${record.message}');
  });

  final log = Logger('Breeze Sqlite');

  group('[Relations]', () {
    test('Fetch Record with Relation (belongsTo)', () async {
      final store = TestStore(
        log: log,
        models: {
          ItemModel.blueprint,
          ItemCategoryModel.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(itemsMigration),
      );

      final query = BreezeQueryById<Item>(1);
      final item = await query.fetch(store);

      expect(item, isNotNull);
      expect(item!.id, equals(1));
      expect(item.name, equals('Item 1'));
      expect(item.category, isNotNull);
      expect(item.category, isA<ItemCategory>());
      expect(item.category!.name, equals('Category 1'));
    });

    test('Fetch All Records with Relation (belongsTo)', () async {
      final store = TestStore(
        log: log,
        models: {
          ItemModel.blueprint,
          ItemCategoryModel.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(itemsMigration),
      );

      final query = BreezeQueryAll<Item>();
      final items = await query.fetch(store);

      expect(items, hasLength(3));

      expect(items[0].id, equals(1));
      expect(items[0].name, equals('Item 1'));
      expect(items[0].category, isNotNull);
      expect(items[0].category, isA<ItemCategory>());
      expect(items[0].category!.name, equals('Category 1'));

      expect(items[1].id, equals(2));
      expect(items[1].name, equals('Item 2'));
      expect(items[1].category, isNotNull);
      expect(items[1].category, isA<ItemCategory>());
      expect(items[1].category!.name, equals('Category 1'));

      expect(items[2].id, equals(3));
      expect(items[2].name, equals('Item 3'));
      expect(items[2].category, isNotNull);
      expect(items[2].category, isA<ItemCategory>());
      expect(items[2].category!.name, equals('Category 2'));
    });

    test('Fetch Record with List Relation (hasMany)', () async {
      final store = TestStore(
        log: log,
        models: {
          ArticleModel.blueprint,
          ArticleTagModel.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(articlesMigration),
      );

      final query = BreezeQueryById<Article>(1);
      final article = await query.fetch(store);

      expect(article, isNotNull);
      expect(article!.id, equals(1));
      expect(article.title, equals('Article 1'));
      expect(article.tags, hasLength(2));
    });

    test('Fetch All Records with Relation (hasManyThrough)', () async {
      final store = TestStore(
        log: log,
        models: {
          ActorModel.blueprint,
          MovieModel.blueprint,
          MovieActorsModel.blueprint,
        },
        migrationStrategy: BreezeSqliteMigrations(manyToManyMigration),
      );

      final query = BreezeQueryAll<Movie>();
      final movies = await query.fetch(store);

      expect(movies, hasLength(2));

      expect(movies[0].id, equals(10));
      expect(movies[0].title, equals('Movie 1'));
      expect(movies[0].actors, isNotNull);
      expect(movies[0].actors, hasLength(2));
      expect(movies[0].actors[0], isA<Actor>());
      expect(movies[0].actors[0].name, equals('Actor 1'));
      expect(movies[0].actors[1], isA<Actor>());
      expect(movies[0].actors[1].name, equals('Actor 2'));

      expect(movies[1].id, equals(20));
      expect(movies[1].title, equals('Movie 2'));
      expect(movies[1].actors, isNotNull);
      expect(movies[1].actors, hasLength(2));
      expect(movies[1].actors[0], isA<Actor>());
      expect(movies[1].actors[0].name, equals('Actor 1'));
      expect(movies[1].actors[1], isA<Actor>());
      expect(movies[1].actors[1].name, equals('Actor 3'));
    });

    // TODO: Test Multilevel nesting: item.category.icon

    // TODO: Test List nesting: category.items
  });

  relationsGroup(
    '[Sqlite Relations]',
    /*
    store: (type, models) async => switch (type) {
      RelationTests.hasOne => TestStore(
        log: log,
        models: models,
        // migrationStrategy: BreezeSqliteMigrations(itemsMigration),
      ),
      _ => TestStore(),
    },
    */
    store: (type, models) async => TestStore(log: log, models: models),
  );

  /*
  // TestCaseGroup()('Class-based group');
  group('Class-based tests', () {
    Test1('source data')();
  });
  */

  group('[Sqlite Relations Auto Migration]', () {
    test('One-to-One', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          CompanyModel.blueprint,
          CompanyAddressModel.blueprint,
        },
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the tables schema version in the database is correct.
      await expectStoreTablesVersions(
        store,
        [
          (CompanyModel.blueprint.name, CompanyModel.blueprint.latestVersion.version),
          (CompanyAddressModel.blueprint.name, CompanyAddressModel.blueprint.latestVersion.version),
        ],
        log,
      );

      // Ensure that the tables structure in the database matches the schema.
      await expectStoreTables(
        store,
        {
          CompanyModel.blueprint.name: [
            (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
            (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          ],
          CompanyAddressModel.blueprint.name: [
            (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
            (name: 'location', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
            (name: 'company_id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: false),
          ],
        },
        log: log,
      );
    });

    test('One-to-Many', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          ArticleModel.blueprint,
          ArticleTagModel.blueprint,
        },
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the tables schema version in the database is correct.
      await expectStoreTablesVersions(
        store,
        [
          (ArticleModel.blueprint.name, ArticleModel.blueprint.latestVersion.version),
          (ArticleTagModel.blueprint.name, ArticleTagModel.blueprint.latestVersion.version),
        ],
        log,
      );

      // Ensure that the tables structure in the database matches the schema.
      await expectStoreTables(
        store,
        {
          ArticleModel.blueprint.name: [
            (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
            (name: 'title', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
            (name: 'text', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          ],
          ArticleTagModel.blueprint.name: [
            (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
            (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
            (name: 'article_id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: false),
          ],
        },
        log: log,
      );
    });

    test('Many-to-One', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          ItemModel.blueprint,
          ItemCategoryModel.blueprint,
        },
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the tables schema version in the database is correct.
      await expectStoreTablesVersions(
        store,
        [
          (ItemModel.blueprint.name, ItemModel.blueprint.latestVersion.version),
          (ItemCategoryModel.blueprint.name, ItemCategoryModel.blueprint.latestVersion.version),
        ],
        log,
      );

      // Ensure that the tables structure in the database matches the schema.
      await expectStoreTables(
        store,
        {
          ItemModel.blueprint.name: [
            (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
            (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
            (name: 'category_id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: false),
          ],
          ItemCategoryModel.blueprint.name: [
            (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
            (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          ],
        },
        log: log,
      );
    });

    test('Many-to-Many', () async {
      final store = BreezeSqliteStore.inMemory(
        models: {
          MovieModel.blueprint,
          ActorModel.blueprint,
          MovieActorsModel.blueprint,
        },
        log: log,
        onInit: (db) => db.execute('PRAGMA temp_store=2'),
        migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
          log: log,
        ),
      );

      await store.database;

      // Ensure that the tables schema version in the database is correct.
      await expectStoreTablesVersions(
        store,
        [
          (MovieModel.blueprint.name, MovieModel.blueprint.latestVersion.version),
          (ActorModel.blueprint.name, ActorModel.blueprint.latestVersion.version),
          (MovieActorsModel.blueprint.name, MovieActorsModel.blueprint.latestVersion.version),
        ],
        log,
      );

      // Ensure that the tables structure in the database matches the schema.
      await expectStoreTables(
        store,
        {
          MovieModel.blueprint.name: [
            (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
            (name: 'title', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          ],
          ActorModel.blueprint.name: [
            (name: 'id', type: 'INTEGER', notNull: false, defaultValue: null, primaryKey: true),
            (name: 'name', type: 'TEXT', notNull: true, defaultValue: null, primaryKey: false),
          ],
          MovieActorsModel.blueprint.name: [
            (name: 'movie_id', type: 'INTEGER', notNull: true, defaultValue: null, primaryKey: false),
            (name: 'actor_id', type: 'INTEGER', notNull: true, defaultValue: null, primaryKey: false),
          ],
        },
        log: log,
      );
    });
  });
}
