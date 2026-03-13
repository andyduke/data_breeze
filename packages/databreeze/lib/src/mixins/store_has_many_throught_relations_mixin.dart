import 'package:databreeze/src/mixins/store_relations_mixin.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/relations/model_relation.dart';
import 'package:databreeze/src/store.dart';

mixin BreezeStoreHasManyThoughRelations on BreezeStore, BreezeStoreRelations {
  @override
  Future<void> fetchHasManyThrough(
    BreezeModelResolvedHasManyThroughRelation relation,
    List<Map<String, dynamic>> records,
    BreezeModelBlueprint relationBlueprint,
  ) {
    // TODO: Implement this
    throw UnimplementedError('Not implemented yet.');
  }

  @override
  Future<void> updateHasManyThroughRelationBeforeSave<M extends BreezeBaseModel>(
    BreezeModelResolvedHasManyThroughRelation relation,
    Map<String, dynamic> record,
  ) {
    // TODO: Implement this
    throw UnimplementedError('Not implemented yet.');
  }
}
