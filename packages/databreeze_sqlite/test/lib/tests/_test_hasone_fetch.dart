part of 'relations_tests.dart';

Future<void> testFetchOneHasOneRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'companies',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 1,
        'name': 'Company 1',
      },
      {
        'id': 2,
        'name': 'Company 2',
      },
    ],
  );
  await store.initCollection(
    'company_addresses',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'location': BreezeTestStoreField(type: String),
      'company_id': BreezeTestStoreField(type: int),
    },
    [
      {
        'id': 1,
        'location': 'Street 1',
        'company_id': 1,
      },
      {
        'id': 2,
        'location': 'Street 2',
        'company_id': 2,
      },
    ],
  );

  final query = BreezeQueryById<Company>(1);
  final company = await query.fetch(store);

  expect(company, isNotNull);
  expect(company!.id, equals(1));
  expect(company.name, equals('Company 1'));

  expect(company.address, isA<CompanyAddress>());
  expect(company.address!.location, equals('Street 1'));
}

Future<void> testFetchAllHasOneRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'companies',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 1,
        'name': 'Company 1',
      },
      {
        'id': 2,
        'name': 'Company 2',
      },
    ],
  );
  await store.initCollection(
    'company_addresses',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'location': BreezeTestStoreField(type: String),
      'company_id': BreezeTestStoreField(type: int),
    },
    [
      {
        'id': 1,
        'location': 'Street 1',
        'company_id': 1,
      },
      {
        'id': 2,
        'location': 'Street 2',
        'company_id': 2,
      },
    ],
  );

  final query = BreezeQueryAll<Company>();
  final companies = await query.fetch(store);

  expect(companies, hasLength(2));

  expect(companies[0].id, equals(1));
  expect(companies[0].name, equals('Company 1'));
  expect(companies[0].address, isA<CompanyAddress>());
  expect(companies[0].address!.location, equals('Street 1'));

  expect(companies[1].id, equals(2));
  expect(companies[1].name, equals('Company 2'));
  expect(companies[1].address, isA<CompanyAddress>());
  expect(companies[1].address!.location, equals('Street 2'));
}
