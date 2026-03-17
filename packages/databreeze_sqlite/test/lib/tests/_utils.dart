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
  required Map<RelationTests, ({Set<BreezeModelBlueprint> models, RelationTestFunction test})> tests,
}) {
  final typeTestNames = {
    RelationTests.hasOne: 'HasOne Relation',
    RelationTests.hasMany: 'HasMany Relation',
    RelationTests.belongsTo: 'BelongsTo Relation',
    RelationTests.hasManyThrough: 'HasManyThrough Relation',
  };

  group(
    description,
    () {
      for (final type in relations) {
        if (relations.contains(type) && tests.containsKey(type)) {
          test(typeTestNames[type], () async {
            final typeTest = tests[type];
            final testStore = await store(type, typeTest?.models ?? {});
            return typeTest?.test(store: testStore);
          });
        }
      }
    },
  );
}
