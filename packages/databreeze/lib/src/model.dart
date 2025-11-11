import 'package:databreeze/src/model_blueprint.dart';
import 'package:meta/meta.dart';

abstract class BreezeBaseModel {}

@immutable
abstract mixin class BreezeViewModel implements BreezeBaseModel {}

abstract mixin class BreezeModel<K> implements BreezeBaseModel {
  /*
  K? get id => _id;
  K? _id;

  @internal
  set id(K? newValue) => _id = newValue;
  */

  K? id;

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
    if (schema.key != null) schema.key!: id,
    ...toRecord(),
  };
}
