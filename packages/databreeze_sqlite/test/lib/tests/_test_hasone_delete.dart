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

  await store.delete(company);

  final companies = await store.fetchAllRecords(table: 'companies');
  expect(
    companies,
    equals([]),
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
