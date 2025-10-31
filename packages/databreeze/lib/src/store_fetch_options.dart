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

// --- Sort

enum BreezeSortDir {
  asc,
  desc,
}

class BreezeOrder {
  final String column;
  final BreezeSortDir direction;

  const BreezeOrder(
    this.column, [
    this.direction = BreezeSortDir.asc,
  ]);
}

class BreezeSortBy {
  final List<BreezeOrder> orders;

  factory BreezeSortBy(String column, [BreezeSortDir direction = BreezeSortDir.asc]) => BreezeSortBy.list([
    BreezeOrder(column, direction),
  ]);

  void sortBy(String column, [BreezeSortDir direction = BreezeSortDir.asc]) {
    orders.add(BreezeOrder(column, direction));
  }

  BreezeSortBy.list([List<BreezeOrder>? orders]) : orders = orders ?? [];

  bool get isEmpty => orders.isEmpty;

  bool get isNotEmpty => orders.isNotEmpty;
}
