part of 'relations_tests.dart';

Future<void> testDeleteNullifyHasOneRelation({
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
      'company_id': BreezeTestStoreField(type: int, isNullable: true),
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
  expect(company!.address, isA<CompanyAddress>());

  await store.delete(company);

  final companies = await store.fetchAllRecords(table: 'companies');
  expect(
    companies,
    equals([
      {
        'id': 2,
        'name': 'Company 2',
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
      {
        'id': 2,
        'location': 'Street 2',
        'company_id': 2,
      },
    ]),
  );
}

Future<void> testDeleteCascadeHasOneRelation({
  required BreezeTestStore store,
}) async {
  await store.initCollection(
    'persons',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'name': BreezeTestStoreField(type: String),
    },
    [
      {
        'id': 1,
        'name': 'Person 1',
      },
      {
        'id': 2,
        'name': 'Person 2',
      },
    ],
  );
  await store.initCollection(
    'person_passports',
    {
      'id': BreezeTestStoreField(type: int, isPrimaryKey: true),
      'passport_number': BreezeTestStoreField(type: String),
      'person_id': BreezeTestStoreField(type: int, isNullable: true),
    },
    [
      {
        'id': 1,
        'passport_number': 'ABC',
        'person_id': 1,
      },
      {
        'id': 2,
        'passport_number': 'DEF',
        'person_id': 2,
      },
    ],
  );

  final query = BreezeQueryById<Person>(1);
  final person = await query.fetch(store);

  expect(person, isNotNull);
  expect(person!.passport, isA<PersonPassport>());

  await store.delete(person);

  final persons = await store.fetchAllRecords(table: 'persons');
  expect(
    persons,
    equals([
      {
        'id': 2,
        'name': 'Person 2',
      },
    ]),
  );

  final passports = await store.fetchAllRecords(table: 'person_passports');
  expect(
    passports,
    equals([
      {
        'id': 2,
        'passport_number': 'DEF',
        'person_id': 2,
      },
    ]),
  );
}
