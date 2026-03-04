import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:logging/logging.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:test/test.dart';

import 'lib/models/item.dart';
import 'lib/models/item_category.dart';
import 'lib/test_store.dart';

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

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.loggerName}] ${record.time} ${record.level.name}: ${record.message}');
  });

  final log = Logger('Breeze Sqlite');

  group('[Relations]', () {
    test('Fetch Record with Relation', () async {
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
      expect(item.category.name, equals('Category 1'));
    });

    test('Fetch All Records with Relation', () async {
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
      expect(items[0].category.name, equals('Category 1'));

      expect(items[1].id, equals(2));
      expect(items[1].name, equals('Item 2'));
      expect(items[1].category, isNotNull);
      expect(items[1].category, isA<ItemCategory>());
      expect(items[1].category.name, equals('Category 1'));

      expect(items[2].id, equals(3));
      expect(items[2].name, equals('Item 3'));
      expect(items[2].category, isNotNull);
      expect(items[2].category, isA<ItemCategory>());
      expect(items[2].category.name, equals('Category 2'));
    });
  });
}
