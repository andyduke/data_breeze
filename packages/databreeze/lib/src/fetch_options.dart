import 'package:databreeze/src/filter.dart';

// TODO: Split into filter, order, pagination/limit?
class BreezeFetchOptions {
  final BreezeFilterExpression? filter;

  const BreezeFetchOptions({
    this.filter,
  });

  // TODO: SortOrder

  // TODO: Pagination
}
