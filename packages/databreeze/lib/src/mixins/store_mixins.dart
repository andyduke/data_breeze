import 'package:databreeze/src/filter.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/store_fetch_options.dart';

mixin BreezeStoreFetch on BreezeStore {
  Future<M?> fetch<M extends BreezeBaseModel>({
    required BreezeFilterExpression filter,
    List<BreezeSortBy> sortBy = const [],
    BreezeModelBlueprint<M>? blueprint,
  }) {
    return fetchWithRequest<M>(
      BreezeFetchRequest(
        filter: filter,
        sortBy: sortBy,
      ),
      blueprint: blueprint,
    );
  }

  Future<List<M>> fetchAll<M extends BreezeBaseModel>({
    BreezeFilterExpression? filter,
    List<BreezeSortBy> sortBy = const [],
    // TODO: Pagination/limit
    BreezeModelBlueprint<M>? blueprint,
  }) {
    return fetchAllWithRequest<M>(
      BreezeFetchRequest(
        filter: filter,
        sortBy: sortBy,
      ),
      blueprint: blueprint,
    );
  }
}
