import 'package:databreeze/databreeze.dart';

class Note extends BreezeModel<int> with NoteModel {
  String title;
  String text;
  DateTime updatedAt;

  Note({
    required this.title,
    required this.text,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
}

mixin NoteModel {
  static final blueprint = BreezeModelBlueprint<Note>.versioned(
    versions: {
      BreezeModelSchemaVersion(
        version: 1,
        name: 'notes',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('title'),
          BreezeModelColumn<String>('text'),
          BreezeModelColumn<DateTime>('updated_at'),
        },
      ),
    },
    builder: fromRecord,
  );

  static Note fromRecord(Map<String, dynamic> map) => Note(
    title: map[title],
    text: map[text],
    updatedAt: map[updatedAt],
  );

  static const id = BreezeField('id');
  static const title = BreezeField('title');
  static const text = BreezeField('text');
  static const updatedAt = BreezeField('updated_at');

  // ---

  Note get _self => this as Note;

  BreezeModelBlueprint get schema => blueprint;

  Map<String, dynamic> toRecord() => {
    title: _self.title,
    text: _self.text,
    updatedAt: _self.updatedAt,
  };
}
