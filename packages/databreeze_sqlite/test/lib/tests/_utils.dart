part of 'relations_tests.dart';

enum RelationTests {
  hasOne,
  hasMany,
  belongsTo,
  hasManyThrough,
}

typedef BreezeTestStoreGetter = Future<BreezeTestStore> Function(RelationTests type, Set<BreezeModelBlueprint> models);

typedef RelationTestFunction = Future<void> Function({required BreezeTestStore store});

void defineRelationGroup(
  String description, {
  required BreezeTestStoreGetter store,
  Set<RelationTests> relations = const {...RelationTests.values},
  required Map<RelationTests, Iterable<({String? label, Set<BreezeModelBlueprint> models, RelationTestFunction test})>>
  tests,
}) {
  final typeTestNames = {
    RelationTests.hasOne: 'HasOne',
    RelationTests.hasMany: 'HasMany',
    RelationTests.belongsTo: 'BelongsTo',
    RelationTests.hasManyThrough: 'HasMany through',
  };

  group(
    description,
    () {
      for (final type in relations) {
        if (relations.contains(type) && tests.containsKey(type)) {
          final typeTests = tests[type]!;
          for (final typeTest in typeTests) {
            final testLabel = (typeTest.label != null)
                ? '${typeTestNames[type]}: ${typeTest.label}'
                : '${typeTestNames[type]}';

            test(testLabel, () async {
              final testStore = await store(type, typeTest.models);
              return typeTest.test(store: testStore);
            });
          }
        }
      }
    },
  );
}
