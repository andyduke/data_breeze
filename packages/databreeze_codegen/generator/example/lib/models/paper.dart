import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'paper.g.dart';

/// Paper model
@BzModel(
  // TODO: primaryKey = id, uuid is unique
  primaryKey: 'uuid',
  name: 'papers',
  // primaryKey: 'note_id',
  // schemaVersionClass: BreezeSqliteModelSchemaVersion,
  schemaHistory: [
    BzSchemaVersion(1, [
      BzSchemaChange.column('title', String),
      BzSchemaChange.column('text', String),
      BzSchemaChange.column('updated_at', DateTime),
      BzSchemaChange.column('version_tag', String),
    ]),
  ],
)
class Paper extends BreezeModel<String> with PaperModel {
  @BzTransient()
  String? get uuid => id;
  set uuid(String? newValue) {
    id = newValue;
  }

  String _title;

  String get title => _title;

  set title(String value) {
    if (_title != value) {
      _title = value;
      _versionTag = null;
    }
  }

  String text;

  DateTime updatedAt;

  String get displayName => title.toUpperCase();

  @BzColumn(name: 'version_tag')
  String? _versionTag;
  String get versionTag => _versionTag ??= _calcVersionTag();
  String _calcVersionTag() => '($title)';

  @BzTransient()
  bool flag = false;

  Paper({
    // required this.uuid,
    required String title,
    required this.text,
    required this.updatedAt,
    String? versionTag,
  }) : _title = title,
       _versionTag = versionTag;
}
