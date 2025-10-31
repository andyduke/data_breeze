import 'dart:collection';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:meta/meta.dart';

abstract class BreezeModel<K> extends UnmodifiableMapBase<String, dynamic> {
  @internal
  bool isFrozen = false;

  bool get isNew => (id == null);

  K? id;

  BreezeModel({
    this.id,
  });

  Future<void> beforeUpdate() async {}

  Future<void> afterUpdate() async {}

  Future<void> beforeDelete() async {}

  Future<void> afterDelete() async {}

  BreezeModelBlueprint get schema;

  Map<String, dynamic> get raw;

  @override
  operator [](Object? key) => raw[key];

  @override
  Iterable<String> get keys => raw.keys;
}
