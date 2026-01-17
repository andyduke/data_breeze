import 'package:databreeze_flutter_example/demo/kvm/kvm_store.dart';
import 'package:databreeze_flutter_example/models/task.dart';
import 'package:logging/logging.dart';

class KvmDemoStore extends KvmStore {
  KvmDemoStore({
    required Logger log,
  }) : super(
         models: {
           Task.blueprint,
         },
         log: log,
       );
}
