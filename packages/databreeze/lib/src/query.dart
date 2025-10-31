import 'package:databreeze/src/filter.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/store_change.dart';

abstract class BreezeQuery<T> {
  const BreezeQuery();

  bool autoUpdateWhen(BreezeStoreChange change);

  Future<T> fetch(BreezeStore store);
}

class BreezeQueryById<T extends BreezeModel> extends BreezeQuery<T?> {
  final int id;
  final BreezeModelBlueprint<T> blueprint;
  final bool autoUpdate;

  const BreezeQueryById(
    this.id, {
    required this.blueprint,
    this.autoUpdate = true,
  });

  @override
  bool autoUpdateWhen(BreezeStoreChange change) => autoUpdate && (change.entity == blueprint.name && change.id == id);

  @override
  Future<T?> fetch(BreezeStore store) async {
    return store.fetch(
      blueprint: blueprint,
      filter: BreezeField(blueprint.key).eq(id),
    );
  }
}

class BreezeQueryAll<T extends BreezeModel> extends BreezeQuery<List<T>> {
  final BreezeFilterExpression? filter;
  final BreezeSortBy? sortBy;
  final BreezeModelBlueprint<T> blueprint;
  final bool autoUpdate;

  const BreezeQueryAll({
    this.filter,
    this.sortBy,
    required this.blueprint,
    this.autoUpdate = true,
  });

  @override
  bool autoUpdateWhen(BreezeStoreChange change) => autoUpdate && (change.entity == blueprint.name);

  @override
  Future<List<T>> fetch(BreezeStore store) async {
    return store.fetchAll(
      blueprint: blueprint,
      filter: filter,
      sortBy: sortBy,
    );
  }
}
