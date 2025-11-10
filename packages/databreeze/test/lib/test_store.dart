import 'package:databreeze/databreeze.dart';

import 'model_types.dart';

class TestStore extends BreezeJsonStore {
  TestStore({
    super.log,
    super.models,
    super.migrationStrategy,
    super.records,
    super.typeConverters,
    super.simulateLatency,
  });

  @override
  Set<BreezeBaseTypeConverter> get defaultTypeConverters => {
    ...super.defaultTypeConverters,
    XFileConverter(),
  };
}
