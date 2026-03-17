import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/sqlite_store.dart';

import 'model_types.dart';
import 'tests/relations_tests.dart';

class TestStore extends BreezeSqliteStore with BreezeTestStore {
  TestStore({
    super.log,
    super.models,
    super.migrationStrategy,
    super.typeConverters,
    super.onInit,
    super.onError,
  }) : super.inMemory();

  @override
  Set<BreezeBaseTypeConverter> get defaultTypeConverters => {
    ...super.defaultTypeConverters,
    XFileConverter(),
  };

  @override
  Future<void> createCollection(String name, Map<String, BreezeTestStoreField> fields) async {
    const sqlTypes = {
      String: 'TEXT',
      int: 'INTEGER',
      double: 'REAL',
      bool: 'INT',
    };

    final sqlFields = [];
    for (final MapEntry(key: fieldName, value: field) in fields.entries) {
      final nullable = (field.isPrimaryKey || field.isNullable) ? '' : ' NOT NULL';
      final pk = field.isPrimaryKey ? ' PRIMARY KEY' : '';
      final options = '$nullable$pk';

      sqlFields.add('  $fieldName ${sqlTypes[field.type]}$options');
    }

    final sql =
        '''CREATE TABLE $name(
${sqlFields.join(',\n')}
)''';

    await executeSql(sql);
  }
}
