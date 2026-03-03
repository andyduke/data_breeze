import 'package:databreeze_annotation/databreeze_annotation.dart';
import 'package:databreeze_generator/src/blueprint_multi_versions_generator.dart';
import 'package:databreeze_generator/src/types.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaVersions', () {
    test('Three versions', () {
      final versions = [
        SchemaVersionChanges(1, [
          SchemaFieldChange.column('name', String),
          SchemaFieldChange.column('content', String, isNullable: true),
          SchemaFieldChange.column('created_at', String),
        ]),
        SchemaVersionChanges(2, [
          SchemaFieldChange.rename('name', to: 'title'),
          SchemaFieldChange.column('updated_at', String),
        ]),
        SchemaVersionChanges(3, [
          SchemaFieldChange.rename('content', to: 'text'),
          SchemaFieldChange.delete('created_at'),
        ]),
      ];

      final fields = <FieldInfo>[
        FieldInfo(name: 'title', type: 'String', isNullable: false),
        FieldInfo(name: 'text', type: 'String', isNullable: true),
        FieldInfo(name: 'updated_at', type: 'String', isNullable: false),
      ];

      final expectedVersions = <SchemaVersion>[
        SchemaVersion(
          version: 1,
          fields: [
            ColumnInfo(name: 'name', type: 'String'),
            ColumnInfo(name: 'content', type: 'String', isNullable: true),
            ColumnInfo(name: 'created_at', type: 'String'),
          ],
        ),
        SchemaVersion(
          version: 2,
          fields: [
            ColumnInfo(name: 'title', prevName: 'name', type: 'String'),
            ColumnInfo(name: 'content', type: 'String', isNullable: true),
            ColumnInfo(name: 'created_at', type: 'String'),
            ColumnInfo(name: 'updated_at', type: 'String'),
          ],
        ),
        SchemaVersion(
          version: 3,
          fields: [
            ColumnInfo(name: 'title', type: 'String'),
            ColumnInfo(name: 'text', prevName: 'content', type: 'String', isNullable: true),
            ColumnInfo(name: 'updated_at', type: 'String'),
          ],
        ),
      ];

      final generator = BlueprintMultiVersionsGenerator(
        className: 'Test',
        tableName: 'test',
        primaryKey: 'id',
        primaryKeyType: 'int',
        fields: fields,
        schemaVersions: versions,
        schemaVersionClass: 'SchemaVersioned',
        nameStyle: BzModelNameStyle.snakeCase,
      );
      final actualVersions = generator.generateVersionedColumns(fields, versions);

      // print('$result');
      for (final v in actualVersions) {
        print('Version: ${v.version}');
        for (final f in v.fields) {
          print('- $f');
        }
        print('===');
      }

      expect(actualVersions, orderedEquals(expectedVersions));
    });

    test('Name style: camelCase', () {
      final versions = [
        SchemaVersionChanges(1, [
          SchemaFieldChange.column('name', String),
          SchemaFieldChange.column('content', String, isNullable: true),
          SchemaFieldChange.column('createdAt', String),
        ]),
      ];

      final fields = <FieldInfo>[
        FieldInfo(name: 'title', type: 'String', isNullable: false),
        FieldInfo(name: 'text', type: 'String', isNullable: true),
        FieldInfo(name: 'createdAt', type: 'String', isNullable: false),
      ];

      final expectedVersions = <SchemaVersion>[
        SchemaVersion(
          version: 1,
          fields: [
            ColumnInfo(name: 'name', type: 'String'),
            ColumnInfo(name: 'content', type: 'String', isNullable: true),
            ColumnInfo(name: 'createdAt', type: 'String'),
          ],
        ),
      ];

      final generator = BlueprintMultiVersionsGenerator(
        className: 'Test',
        tableName: 'test',
        primaryKey: 'id',
        primaryKeyType: 'int',
        fields: fields,
        schemaVersions: versions,
        schemaVersionClass: 'SchemaVersioned',
        nameStyle: BzModelNameStyle.camelCase,
      );
      final actualVersions = generator.generateVersionedColumns(fields, versions);

      // print('$result');
      for (final v in actualVersions) {
        print('Version: ${v.version}');
        for (final f in v.fields) {
          print('- $f');
        }
        print('===');
      }

      expect(actualVersions, orderedEquals(expectedVersions));
    });
  });
}
