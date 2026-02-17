import 'package:databreeze/src/filter.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/store_fetch_options.dart';
import 'package:databreeze/src/type_converters.dart';

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

  Future<T?> fetchColumn<T>({
    required String table,
    required String column,
    required BreezeFilterExpression filter,
    List<BreezeSortBy> sortBy = const [],
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  }) async {
    assert(T != dynamic, 'The return type must be specified.');

    final rawResult = await fetchColumnWithRequest(
      table: table,
      column: column,
      request: BreezeFetchRequest(
        filter: filter,
        sortBy: sortBy,
      ),
      typeConverters: typeConverters,
    );

    final converters = {
      ...this.typeConverters,
      ...typeConverters,
    };

    final result = toDartValue(rawResult, dartType: T, converters: converters);

    return result;
  }

  Future<List<T>> fetchColumnAll<T>({
    required String table,
    required String column,
    BreezeFilterExpression? filter,
    List<BreezeSortBy> sortBy = const [],
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  }) async {
    assert(T != dynamic, 'The return type must be specified.');

    final rawResult = await fetchColumnAllWithRequest(
      table: table,
      column: column,
      request: BreezeFetchRequest(
        filter: filter,
        sortBy: sortBy,
      ),
      typeConverters: typeConverters,
    );

    final converters = {
      ...this.typeConverters,
      ...typeConverters,
    };

    final result = rawResult
        .map((r) => toDartValue(r, dartType: T, converters: converters))
        .cast<T>()
        .toList(growable: false);

    return result;
  }
}
