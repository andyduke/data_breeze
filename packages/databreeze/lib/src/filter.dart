/// Base class for all filter expressions used in queries.
abstract class BreezeFilterExpression {
  const BreezeFilterExpression();
}

/// A comparison filter (e.g., `field == value`, `field > value`).
class BreezeComparisonFilter extends BreezeFilterExpression {
  final String field;
  final String operator;
  final dynamic value;

  const BreezeComparisonFilter(this.field, this.operator, this.value);
}

/// A filter that checks if a field is between two values (inclusive).
class BreezeBetweenFilter extends BreezeFilterExpression {
  final String field;
  final dynamic min;
  final dynamic max;

  const BreezeBetweenFilter(this.field, this.min, this.max);
}

/// A filter that checks if a field is in a list of values.
class BreezeInFilter extends BreezeFilterExpression {
  final String field;
  final List<dynamic> values;
  final bool inverse;

  const BreezeInFilter(this.field, this.values, {this.inverse = false});
}

/// A logical AND filter combining two expressions.
class BreezeAndFilter extends BreezeFilterExpression {
  final BreezeFilterExpression left;
  final BreezeFilterExpression right;

  const BreezeAndFilter(this.left, this.right);
}

/// A logical OR filter combining two expressions.
class BreezeOrFilter extends BreezeFilterExpression {
  final BreezeFilterExpression left;
  final BreezeFilterExpression right;

  const BreezeOrFilter(this.left, this.right);
}

/// Extension methods for combining filters using `&` and `|`.
extension BreezeFilterOps on BreezeFilterExpression {
  /// Combines this filter with [other] using logical AND.
  BreezeFilterExpression operator &(BreezeFilterExpression other) => BreezeAndFilter(this, other);

  /// Combines this filter with [other] using logical OR.
  BreezeFilterExpression operator |(BreezeFilterExpression other) => BreezeOrFilter(this, other);
}

/// Represents a field in a query, used to build filter expressions.
class BreezeField {
  final String name;

  const BreezeField(this.name);

  /// Creates a filter for equality.
  BreezeFilterExpression eq(dynamic value) => BreezeComparisonFilter(name, '==', value);

  /// Creates a filter for inequality.
  BreezeFilterExpression notEq(dynamic value) => BreezeComparisonFilter(name, '!=', value);

  /// Creates a filter for less than.
  BreezeFilterExpression operator <(dynamic value) => BreezeComparisonFilter(name, '<', value);

  /// Creates a filter for less than or equal.
  BreezeFilterExpression operator <=(dynamic value) => BreezeComparisonFilter(name, '<=', value);

  /// Creates a filter for greater than.
  BreezeFilterExpression operator >(dynamic value) => BreezeComparisonFilter(name, '>', value);

  /// Creates a filter for greater than or equal.
  BreezeFilterExpression operator >=(dynamic value) => BreezeComparisonFilter(name, '>=', value);

  /// Creates a filter for a value between [min] and [max].
  BreezeFilterExpression between(dynamic min, dynamic max) => BreezeBetweenFilter(name, min, max);

  /// Creates a filter for a value inside a list of [values].
  BreezeFilterExpression inside(List<dynamic> values) => BreezeInFilter(name, values);

  /// Creates a filter for a value not inside a list of [values].
  BreezeFilterExpression notInside(List<dynamic> values) => BreezeInFilter(name, values, inverse: true);
}
