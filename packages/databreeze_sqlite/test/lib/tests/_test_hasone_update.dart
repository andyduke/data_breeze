part of 'relations_tests.dart';

Future<void> testAddHasOneRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'companies',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
    },
    [],
  );
  await store.initCollection(
    'company_addresses',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'location': BreezeTestStoreField(type: String),
      'company_id': BreezeTestStoreField(type: int),
    },
    [],
  );

  final company = Company(
    name: 'Company 1',
    address: CompanyAddress(
      location: 'Street 1',
    ),
  );

  await store.save(company);

  expect(company.isNew, isFalse);
  expect(company.id, isNotNull);

  expect(company.address, isNotNull);
  expect(company.address!.isNew, isFalse);
  expect(company.address!.id, isNotNull);

  final companies = await store.fetchAllRecords(table: 'companies');
  expect(
    companies,
    equals([
      {
        'id': 1,
        'name': 'Company 1',
      },
    ]),
  );

  final addreses = await store.fetchAllRecords(table: 'company_addresses');
  expect(
    addreses,
    equals([
      {
        'id': 1,
        'location': 'Street 1',
        'company_id': 1,
      },
    ]),
  );
}

Future<void> testUpdateHasOneRelation({
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
    ],
  );

  final query = BreezeQueryById<Company>(1);
  final company = await query.fetch(store);

  expect(company, isNotNull);
  expect(company!.address, isA<CompanyAddress>());

  company.name = 'Company 1*';
  company.address?.location = 'Street 1*';
  await store.save(company);

  final companies = await store.fetchAllRecords(table: 'companies');
  expect(
    companies,
    equals([
      {
        'id': 1,
        'name': 'Company 1*',
      },
    ]),
  );

  final addreses = await store.fetchAllRecords(table: 'company_addresses');
  expect(
    addreses,
    equals([
      {
        'id': 1,
        'location': 'Street 1*',
        'company_id': 1,
      },
    ]),
  );
}

Future<void> testUnsetHasOneRelation({
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
    ],
  );
  await store.initCollection(
    'company_addresses',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'location': BreezeTestStoreField(type: String),
      'company_id': BreezeTestStoreField(type: int, isNullable: true),
    },
    [
      {
        'id': 1,
        'location': 'Street 1',
        'company_id': 1,
      },
    ],
  );

  final query = BreezeQueryById<Company>(1);
  final company = await query.fetch(store);

  expect(company, isNotNull);
  expect(company!.address, isA<CompanyAddress>());

  company.address = null;
  await store.save(company);

  final companies = await store.fetchAllRecords(table: 'companies');
  expect(
    companies,
    equals([
      {
        'id': 1,
        'name': 'Company 1',
      },
    ]),
  );

  final addreses = await store.fetchAllRecords(table: 'company_addresses');
  expect(
    addreses,
    equals([
      {
        'id': 1,
        'location': 'Street 1',
        'company_id': null,
      },
    ]),
  );
}
