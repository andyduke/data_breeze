import 'package:databreeze/src/model_blueprint.dart';
import 'package:meta/meta.dart';

abstract class BreezeAbstractModel<K> {
  K? id;
}

// TODO: Remove the ID, since the view model may not have a key?
abstract mixin class BreezeModelView<K> implements BreezeAbstractModel<K> {
  @override
  K? get id => _id;
  K? _id;
  @override
  @internal
  set id(K? newValue) => _id = newValue;
}

abstract mixin class BreezeModel<K> implements BreezeAbstractModel<K> {
  @override
  K? get id => _id;
  K? _id;
  @override
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
