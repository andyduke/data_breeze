import 'package:databreeze/databreeze.dart';

import 'json_store.dart';
import 'model_types.dart';

class TestStore extends JsonStore {
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
