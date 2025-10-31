import 'package:databreeze/src/model_blueprint.dart';
import 'package:meta/meta.dart';

abstract class BreezeModel<K> {
  @internal
  bool isFrozen = false;

  bool get isNew => (id == null);

  K? get id => _id;
  K? _id;

  @internal
  set id(K? newValue) => _id = newValue;

  BreezeModel({
    K? id,
  }) : _id = id;

  Future<void> afterAdd() async {}

  Future<void> beforeUpdate() async {}

  Future<void> afterUpdate() async {}

  Future<void> beforeDelete() async {}

  Future<void> afterDelete() async {}

  BreezeModelBlueprint get schema;

  Map<String, dynamic> toRecord();
}
