import 'package:databreeze/src/fetch_options.dart';
import 'package:databreeze/src/filter.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/store_change.dart';

abstract class BreezeQuery<T> {
  const BreezeQuery();

  bool autoUpdateWhen(BreezeStoreChange change);

  Future<T> fetch(BreezeStore store);
}

class BreezeQueryById<T> extends BreezeQuery<T?> {
  final int id;
  final BreezeModelBlueprint blueprint;
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
      options: BreezeFetchOptions(
        filter: BreezeField(blueprint.key).eq(id),
      ),
    );
  }
}

class BreezeQueryAll<T> extends BreezeQuery<List<T>> {
  final BreezeFilterExpression? filter;
  final BreezeModelBlueprint blueprint;
  final bool autoUpdate;

  const BreezeQueryAll({
    this.filter,
    required this.blueprint,
    this.autoUpdate = true,
  });

  @override
  bool autoUpdateWhen(BreezeStoreChange change) => autoUpdate && (change.entity == blueprint.name);

  @override
  Future<List<T>> fetch(BreezeStore store) async {
    return store.fetchAll(
      blueprint: blueprint,
      options: BreezeFetchOptions(
        filter: filter,
      ),
    );
  }
}
