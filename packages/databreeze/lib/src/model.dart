import 'package:databreeze/src/model_blueprint.dart';
import 'package:meta/meta.dart';

abstract class BreezeAbstractModel {}

abstract mixin class BreezeModelView<K> implements BreezeAbstractModel {}

abstract mixin class BreezeModel<K> implements BreezeAbstractModel {
  K? get id => _id;
  K? _id;

  @internal
  set id(K? newValue) => _id = newValue;

  @internal
  bool isFrozen = false;

  bool get isNew => (id == null);

  Future<void> afterAdd() async {}

  Future<void> beforeUpdate() async {}

  Future<void> afterUpdate() async {}

  Future<void> beforeDelete() async {}

  Future<void> afterDelete() async {}

  BreezeModelBlueprint get schema;

  Map<String, dynamic> toRecord();

  @internal
  Map<String, dynamic> toRawRecord() => {
    schema.key: id,
    ...toRecord(),
  };
}
