// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_example.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin CaseExampleModel {
  static final blueprint = BreezeModelBlueprint<CaseExample>.versioned(
    versions: {
      BreezeModelSchemaVersion(
        version: 1,
        name: 'caseExample',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('title'),
          BreezeModelColumn<String?>('noteText'),
        },
      ),
    },
    builder: CaseExampleModel.fromRecord,
  );

  static CaseExample fromRecord(Map<String, dynamic> map) => CaseExample(
    title: map[CaseExampleModel.title],
    noteText: map[CaseExampleModel.noteText],
  );

  static const id = BreezeField('id');
  static const title = BreezeField('title');
  static const noteText = BreezeField('noteText');

  // ---

  CaseExample get _self => this as CaseExample;

  BreezeModelBlueprint get schema => CaseExampleModel.blueprint;

  Map<String, dynamic> toRecord() => {
    CaseExampleModel.title: _self.title,
    CaseExampleModel.noteText: _self.noteText,
  };
}
