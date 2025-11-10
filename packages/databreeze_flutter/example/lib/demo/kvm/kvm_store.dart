import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter_example/models/model_types.dart';

class KvmStore extends BreezeJsonStore {
  KvmStore({
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
