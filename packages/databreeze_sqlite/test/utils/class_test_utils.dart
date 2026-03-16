import 'package:meta/meta.dart';
import 'package:test/expect.dart';
import 'package:test/test.dart' as t;

abstract class TestCase {
  final Object? description;

  const TestCase({
    required this.description,
  });

  @protected
  dynamic test();

  @isTest
  Future<void> call() async {
    t.test(description, test);
  }
}

/*
class TestCaseGroup {
  @isTestGroup
  void call(Object? description) {}
}
*/

// ---

class Test1 extends TestCase {
  final String source;

  const Test1(this.source) : super(description: 'Test1');

  @override
  test() async {
    expect(source, isNotEmpty);
  }
}
