import 'package:sqlite_async/sqlite_async.dart';

import '../test_utils.dart';

final createProductsTableSql = '''CREATE TABLE products(
    id INTEGER PRIMARY KEY,
    name TEXT,
    price REAL NULL
)''';

SqliteMigrations createProductsMigration(List<Map<String, dynamic>> entries) => createMigrations([
  createProductsTableSql,
  for (final entry in entries)
    "INSERT INTO products(id, name, price) VALUES(${entry['id'] ?? 'NULL'}, '${entry['name']}', ${entry['price'] ?? 'NULL'})",
]);
