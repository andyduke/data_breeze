import 'package:databreeze/src/filter.dart';

// --- Sort

enum BreezeSortDir {
  asc,
  desc,
}

class BreezeSortBy {
  final String column;
  final BreezeSortDir direction;

  const BreezeSortBy(
    this.column, [
    this.direction = BreezeSortDir.asc,
  ]);
}

// TODO: pagination/limit?

// --- Fetch Request

abstract class BreezeAbstractFetchRequest {
  const BreezeAbstractFetchRequest();
}

class BreezeFetchRequest extends BreezeAbstractFetchRequest {
  final BreezeFilterExpression? filter;
  final List<BreezeSortBy> sortBy;
  // TODO: pagination/limit

  const BreezeFetchRequest({
    this.filter,
    this.sortBy = const [],
  });

  @override
  String toString() =>
      '''BreezeFetchRequest(
  filter: $filter,
  sortBy: $sortBy
)''';
}
