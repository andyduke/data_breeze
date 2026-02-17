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
          BreezeModelColumn<String>('uuid', isPrimaryKey: true),
          BreezeModelColumn<String>('title'),
          BreezeModelColumn<String>('text'),
          BreezeModelColumn<DateTime>('updated_at'),
          BreezeModelColumn<String>('version_tag'),
        },
      ),
    },
    builder: PaperModel.fromRecord,
  );

  static Paper fromRecord(Map<String, dynamic> map) => Paper(
    uuid: map[PaperModel.uuid],
    title: map[PaperModel.title],
    text: map[PaperModel.text],
    updatedAt: map[PaperModel.updatedAt],
    versionTag: map[PaperModel.versionTag],
  );

  static const id = BreezeField('uuid');
  static const uuid = BreezeField('uuid');
  static const title = BreezeField('title');
  static const text = BreezeField('text');
  static const updatedAt = BreezeField('updated_at');
  static const versionTag = BreezeField('version_tag');

  // ---

  Paper get _self => this as Paper;

  BreezeModelBlueprint get schema => PaperModel.blueprint;

  Map<String, dynamic> toRecord() => {
    PaperModel.uuid: _self.uuid,
    PaperModel.title: _self.title,
    PaperModel.text: _self.text,
    PaperModel.updatedAt: _self.updatedAt,
    PaperModel.versionTag: _self._versionTag,
  };
}
