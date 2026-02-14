// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin NoteModel {
  static final blueprint = BreezeModelBlueprint<Note>.versioned(
    versions: {
      BreezeModelSchemaVersion(
        version: 1,
        name: 'my_notes',
        columns: {
          BreezeModelColumn<int>('note_id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
          BreezeModelColumn<String?>('note_text'),
        },
      ),

      BreezeModelSchemaVersion(
        version: 2,
        name: 'my_notes',
        columns: {
          BreezeModelColumn<int>('note_id', isPrimaryKey: true),
          BreezeModelColumn<String>('title', prevName: 'name'),
          BreezeModelColumn<String?>('note_text'),
          BreezeModelColumn<DateTime>('updated_at'),
        },
      ),
    },
    builder: NoteModel.fromRecord,
  );

  static Note fromRecord(Map<String, dynamic> map) => Note(
    title: map[NoteModel.title],
    content: map[NoteModel.content],
    updatedAt: map[NoteModel.updatedAt],
  );

  static const id = BreezeField('note_id');
  static const title = BreezeField('title');
  static const content = BreezeField('note_text');
  static const updatedAt = BreezeField('updated_at');

  // ---

  Note get _self => this as Note;

  BreezeModelBlueprint get schema => NoteModel.blueprint;

  Map<String, dynamic> toRecord() => {
    NoteModel.title: _self.title,
    NoteModel.content: _self.content,
    NoteModel.updatedAt: _self.updatedAt,
  };
}
