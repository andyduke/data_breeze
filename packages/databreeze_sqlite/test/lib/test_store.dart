import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/sqlite_store.dart';

import 'model_types.dart';

class TestStore extends BreezeSqliteStore {
  TestStore({
    super.log,
    super.models,
    super.migrations,
    super.typeConverters,
  }) : super(onPath: () async => null);

  @override
  Set<BreezeBaseTypeConverter> get defaultTypeConverters => {
    ...super.defaultTypeConverters,
    XFileConverter(),
  };
}
