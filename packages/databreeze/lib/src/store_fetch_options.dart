// TODO: pagination/limit?

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
