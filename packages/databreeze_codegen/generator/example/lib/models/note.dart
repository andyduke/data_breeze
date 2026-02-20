import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'note.g.dart';

/// Note model
@BzModel(
  name: 'my_notes',
  // primaryKey: 'note_id',
  // schemaVersionClass: BreezeSqliteModelSchemaVersion,
  schemaHistory: [
    BzSchemaVersion(1, [
      BzSchemaChange.column('name', String),
      BzSchemaChange.column('note_text', String, isNullable: true),
    ]),
    BzSchemaVersion(2, [
      BzSchemaChange.rename('name', to: 'title'),
      BzSchemaChange.column('updated_at', DateTime),
    ]),
  ],
)
class Note extends BreezeModel<int> with NoteModel {
  String title;

  @BzColumn(name: 'note_text')
  String? content;

  DateTime updatedAt;

  @BzTransient()
  bool flag = false;

  Note({
    required this.title,
    required this.content,
    required this.updatedAt,
  });
}
