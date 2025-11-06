import 'package:databreeze/src/filter.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/store_change.dart';
import 'package:meta/meta.dart';

// TODO: Refactor - extract blueprint property to BreezeQueryWithBlueprint;
//  BreezeQueryById & BreezeQueryAll must extends BreezeQueryWithBlueprint
abstract class BreezeQuery<M extends BreezeBaseModel, R> {
  BreezeQuery({
    BreezeModelBlueprint<M>? blueprint,
  }) : _blueprint = blueprint;

  final BreezeModelBlueprint<M>? _blueprint;

  /// The blueprint of the query model.
  ///
  /// If the blueprint is not specified when creating the query class,
  /// it will be determined later, immediately before the first
  /// execution of the query.
  @protected
  late BreezeModelBlueprint<M>? blueprint = _blueprint;

  bool autoUpdateWhen(BreezeStoreChange change);

  Future<R> fetch(BreezeStore store) {
    if (_blueprint == null && blueprint == null) {
      blueprint = store.blueprintOf(M) as BreezeModelBlueprint<M>?;
    }

    return exec(store);
  }

  @protected
  Future<R> exec(BreezeStore store);
}

class BreezeQueryById<M extends BreezeBaseModel> extends BreezeQuery<M, M?> {
  final int id;
  final bool autoUpdate;

  BreezeQueryById(
    this.id, {
    super.blueprint,
    this.autoUpdate = true,
  });

  @override
  bool autoUpdateWhen(BreezeStoreChange change) => autoUpdate && (change.entity == blueprint?.name && change.id == id);

  @override
  Future<M?> exec(BreezeStore store) async {
    if (blueprint!.key == null) {
      throw Exception('This model does not have a primary key field.');
    }

    return store.fetch(
      blueprint: blueprint /* as BreezeModelBlueprint<M>*/,
      filter: BreezeField(blueprint!.key!).eq(id),
    );
  }
}

class BreezeQueryAll<M extends BreezeBaseModel> extends BreezeQuery<M, List<M>> {
  final BreezeFilterExpression? filter;
  final List<BreezeSortBy> sortBy;
  final bool autoUpdate;

  BreezeQueryAll({
    this.filter,
    this.sortBy = const [],
    super.blueprint,
    this.autoUpdate = true,
  });

  @override
  bool autoUpdateWhen(BreezeStoreChange change) => autoUpdate && (change.entity == blueprint?.name);

  @override
  Future<List<M>> exec(BreezeStore store) async {
    return store.fetchAll(
      blueprint: blueprint /* as BreezeModelBlueprint<M>*/,
      filter: filter,
      sortBy: sortBy,
    );
  }
}
