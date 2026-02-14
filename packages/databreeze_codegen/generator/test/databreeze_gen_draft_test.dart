import 'package:collection/collection.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';
import 'package:test/test.dart';

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

extension type const CopyValue(String str) implements String {
  const CopyValue.empty() : str = '';
}

class _ColumnInfo {
  final String name;
  final String? prevName;
  final String type;
  final bool isNullable;

  _ColumnInfo({
    required this.name,
    this.prevName,
    required this.type,
    this.isNullable = false,
  });

  _ColumnInfo copyWith({
    String? name,
    String? prevName,
    String? type,
    bool? isNullable,
  }) {
    return _ColumnInfo(
      name: name ?? this.name,
      prevName: (prevName == CopyValue.empty()) ? null : (prevName ?? this.prevName),
      type: type ?? this.type,
      isNullable: isNullable ?? this.isNullable,
    );
  }

  @override
  bool operator ==(covariant _ColumnInfo other) =>
      (name == other.name) && (prevName == other.prevName) && (type == other.type) && (isNullable == other.isNullable);

  @override
  int get hashCode => Object.hash(name, prevName, type, isNullable);

  @override
  String toString() =>
      '$name: $type${(' (${[
        if (prevName != null) 'prev: $prevName',
        'isNullable: $isNullable',
      ].join(', ')})')}';
}

class _SchemaVersion {
  final int version;
  final List<_ColumnInfo> fields;

  const _SchemaVersion({
    required this.version,
    required this.fields,
  });

  @override
  bool operator ==(covariant _SchemaVersion other) => (version == other.version) && (listEquals(fields, other.fields));

  @override
  int get hashCode => Object.hash(version, fields);

  @override
  String toString() =>
      '''_Version(
  version: $version,
  fields: $fields,
)''';
}

List<_ColumnInfo> _applyChanges(List<_ColumnInfo> fields, List<BzSchemaChange> changes) {
  final result = [...fields];

  for (final change in changes) {
    switch (change) {
      case BzAppendField(name: final name, type: final type, isNullable: final isNullable):
        final idx = result.indexWhere((f) => f.name == name);
        if (idx == -1) {
          result.add(
            _ColumnInfo(
              name: name,
              type: type.toString(),
              isNullable: isNullable,
            ),
          );
        }
        break;

      case BzRenameField(from: final from, to: final to):
        final idx = result.indexWhere((f) => f.name == to);
        if (idx != -1) {
          result[idx] = result[idx].copyWith(name: to, prevName: from);
        }
        break;

      case BzDeleteField(name: final name):
        final idx = result.indexWhere((f) => f.name == name);
        if (idx != -1) {
          result.removeAt(idx);
        }
        break;
    }
  }

  return result;
}

List<_ColumnInfo> _undoChanges(
  List<_ColumnInfo> fields,
  List<BzSchemaChange> changes,
  List<BzSchemaVersion> prevVersions,
) {
  final result = [...fields];

  for (final change in changes) {
    switch (change) {
      case BzAppendField(name: final name):
        final idx = result.indexWhere((f) => f.name == name);
        if (idx != -1) {
          result.removeAt(idx);
        }
        break;

      case BzRenameField(from: final from, to: final to):
        final idx = result.indexWhere((f) => f.name == to);
        if (idx != -1) {
          result[idx] = result[idx].copyWith(name: from, prevName: CopyValue.empty());
        }
        break;

      case BzDeleteField(name: final name):
        BzAppendField? column;
        for (final version in prevVersions.reversed) {
          column = version.changes.firstWhereOrNull((c) => (c is BzAppendField) && (c.name == name)) as BzAppendField?;
          if (column != null) break;
        }

        if (column != null) {
          result.add(
            _ColumnInfo(
              name: column.name,
              type: column.type.toString(),
              isNullable: column.isNullable,
            ),
          );
        }

        break;
    }
  }

  return result;
}

List<_SchemaVersion> _generateVersions(List<_ColumnInfo> fields, List<BzSchemaVersion> versions) {
  List<_ColumnInfo> currentFields = [...fields];
  final result = <_SchemaVersion>[];

  for (var i = (versions.length - 1); i >= 0; i--) {
    final version = versions[i];

    final versionFields = _applyChanges(currentFields, version.changes);
    result.add(
      _SchemaVersion(
        version: version.version,
        fields: versionFields,
      ),
    );

    final List<BzSchemaVersion> prevVersions = (i > 0) ? versions.sublist(0, i - 1) : [];
    currentFields = _undoChanges(currentFields, version.changes, prevVersions);
  }

  return result.reversed.toList(growable: false);
}

void main() {
  group('SchemaVersions', () {
    test('Three versions', () {
      final versions = [
        BzSchemaVersion(1, [
          BzSchemaChange.column('name', String),
          BzSchemaChange.column('content', String, isNullable: true),
          BzSchemaChange.column('created_at', String),
        ]),
        BzSchemaVersion(2, [
          BzSchemaChange.rename('name', to: 'title'),
          BzSchemaChange.column('updated_at', String),
        ]),
        BzSchemaVersion(3, [
          BzSchemaChange.rename('content', to: 'text'),
          BzSchemaChange.delete('created_at'),
        ]),
      ];

      final fields = <_ColumnInfo>[
        _ColumnInfo(name: 'title', type: 'String'),
        _ColumnInfo(name: 'text', type: 'String', isNullable: true),
        _ColumnInfo(name: 'updated_at', type: 'String'),
      ];

      final expectedVersions = <_SchemaVersion>[
        _SchemaVersion(
          version: 1,
          fields: [
            _ColumnInfo(name: 'name', type: 'String'),
            _ColumnInfo(name: 'content', type: 'String', isNullable: true),
            _ColumnInfo(name: 'created_at', type: 'String'),
          ],
        ),
        _SchemaVersion(
          version: 2,
          fields: [
            _ColumnInfo(name: 'title', prevName: 'name', type: 'String'),
            _ColumnInfo(name: 'content', type: 'String', isNullable: true),
            _ColumnInfo(name: 'updated_at', type: 'String'),
            _ColumnInfo(name: 'created_at', type: 'String'),
          ],
        ),
        _SchemaVersion(
          version: 3,
          fields: [
            _ColumnInfo(name: 'title', type: 'String'),
            _ColumnInfo(name: 'text', prevName: 'content', type: 'String', isNullable: true),
            _ColumnInfo(name: 'updated_at', type: 'String'),
          ],
        ),
      ];

      final actualVersions = _generateVersions(fields, versions);

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
