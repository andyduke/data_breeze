import 'package:databreeze/databreeze.dart';
import 'package:test/test.dart';

Future<void> main() async {
  group('JsonStore', () {
    final store = BreezeJsonStore();

    group('Comparison filters', () {
      test('eq returns true when values match', () {
        final expr = BreezeField('name').eq('John');
        expect(store.applyFilter({'name': 'John'}, expr), isTrue);
      });

      test('eq returns false when values differ', () {
        final expr = BreezeField('name').eq('John');
        expect(store.applyFilter({'name': 'Alice'}, expr), isFalse);
      });

      test('greater than works correctly', () {
        final expr = BreezeField('age') > 30;
        expect(store.applyFilter({'age': 35}, expr), isTrue);
        expect(store.applyFilter({'age': 25}, expr), isFalse);
      });

      test('less than works correctly', () {
        final expr = BreezeField('age') < 30;
        expect(store.applyFilter({'age': 25}, expr), isTrue);
        expect(store.applyFilter({'age': 35}, expr), isFalse);
      });
    });

    group('Between filter', () {
      test('returns true when value is within range', () {
        final expr = BreezeField('score').between(50, 100);
        expect(store.applyFilter({'score': 75}, expr), isTrue);
      });

      test('returns false when value is outside range', () {
        final expr = BreezeField('score').between(50, 100);
        expect(store.applyFilter({'score': 120}, expr), isFalse);
      });
    });

    group('In/NotIn filters', () {
      test('inside returns true when value is in list', () {
        final expr = BreezeField('status').inside(['active', 'pending']);
        expect(store.applyFilter({'status': 'active'}, expr), isTrue);
      });

      test('inside returns false when value not in list', () {
        final expr = BreezeField('status').inside(['active', 'pending']);
        expect(store.applyFilter({'status': 'inactive'}, expr), isFalse);
      });

      test('notInside returns true when value not in list', () {
        final expr = BreezeField('status').notInside(['inactive']);
        expect(store.applyFilter({'status': 'active'}, expr), isTrue);
      });

      test('notInside returns false when value is in list', () {
        final expr = BreezeField('status').notInside(['inactive']);
        expect(store.applyFilter({'status': 'inactive'}, expr), isFalse);
      });
    });

    group('Logical filters', () {
      test('AND returns true when both sides true', () {
        final expr = (BreezeField('age') > 30) & BreezeField('name').eq('John');
        expect(store.applyFilter({'age': 35, 'name': 'John'}, expr), isTrue);
      });

      test('AND returns false when one side false', () {
        final expr = (BreezeField('age') > 30) & BreezeField('name').eq('John');
        expect(store.applyFilter({'age': 25, 'name': 'John'}, expr), isFalse);
      });

      test('OR returns true when one side true', () {
        final expr = (BreezeField('age') > 30) | BreezeField('name').eq('John');
        expect(store.applyFilter({'age': 25, 'name': 'John'}, expr), isTrue);
      });

      test('OR returns false when both sides false', () {
        final expr = (BreezeField('age') > 30) | BreezeField('name').eq('John');
        expect(store.applyFilter({'age': 25, 'name': 'Alice'}, expr), isFalse);
      });

      test('NOT inverts result', () {
        final expr = ~(BreezeField('age') > 30);
        expect(store.applyFilter({'age': 25}, expr), isTrue);
        expect(store.applyFilter({'age': 35}, expr), isFalse);
      });

      test('NOT inverts result of a complex expression', () {
        final expr = ~(BreezeField('name').eq('John') & (BreezeField('age') > 30));
        expect(store.applyFilter({'name': 'John', 'age': 25}, expr), isTrue);
        expect(store.applyFilter({'name': 'John', 'age': 35}, expr), isFalse);
        expect(store.applyFilter({'name': 'Bill', 'age': 35}, expr), isTrue);
      });
    });
  });
}
