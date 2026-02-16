// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paper.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin PaperModel {
  static final blueprint = BreezeModelBlueprint<Paper>.versioned(
    versions: {
      BreezeModelSchemaVersion(
        version: 1,
        name: 'papers',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('title'),
          BreezeModelColumn<String>('text'),
          BreezeModelColumn<DateTime>('updated_at'),
        },
      ),
    },
    builder: PaperModel.fromRecord,
  );

  static Paper fromRecord(Map<String, dynamic> map) => Paper(
    title: map[PaperModel.title],
    text: map[PaperModel.text],
    updatedAt: map[PaperModel.updatedAt],
  );

  static const id = BreezeField('id');
  static const title = BreezeField('title');
  static const text = BreezeField('text');
  static const updatedAt = BreezeField('updated_at');

  // ---

  Paper get _self => this as Paper;

  BreezeModelBlueprint get schema => PaperModel.blueprint;

  Map<String, dynamic> toRecord() => {
    PaperModel.title: _self.title,
    PaperModel.text: _self.text,
    PaperModel.updatedAt: _self.updatedAt,
  };
}
