import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'paper.g.dart';

/// Note model
@BzModel(
  name: 'papers',
  // primaryKey: 'note_id',
  // schemaVersionClass: BreezeSqliteModelSchemaVersion,
  schemaHistory: [
    BzSchemaVersion(1, [
      BzSchemaChange.column('title', String),
      BzSchemaChange.column('text', String),
      BzSchemaChange.column('updated_at', DateTime),
    ]),
  ],
)
class Paper extends BreezeModel<int> with PaperModel {
  String _title;

  String get title => _title;

  set title(String value) {
    if (_title != value) {
      _title = value;
    }
  }

  String text;

  DateTime updatedAt;

  String get versionTag => '($title)';

  @BzTransient()
  bool flag = false;

  Paper({
    required String title,
    required this.text,
    required this.updatedAt,
  }) : _title = title;
}
