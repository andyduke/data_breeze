// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deletion_info.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin DeletionInfoModel {
  static final blueprint = BreezeModelBlueprint<DeletionInfo>.versioned(
    versions: {
      BreezeModelSchemaVersion(
        version: 1,
        name: 'deletion_info',
        columns: {
          BreezeModelColumn<String>('table', isPrimaryKey: true),
          BreezeModelColumn<DateTime>('timestamp'),
        },
      ),
    },
    builder: DeletionInfoModel.fromRecord,
  );

  static DeletionInfo fromRecord(Map<String, dynamic> map) =>
      DeletionInfo._(timestamp: map[DeletionInfoModel.timestamp]);

  static const id = BreezeField('table');
  static const timestamp = BreezeField('timestamp');

  // ---

  DeletionInfo get _self => this as DeletionInfo;

  BreezeModelBlueprint get schema => DeletionInfoModel.blueprint;

  Map<String, dynamic> toRecord() => {
    DeletionInfoModel.timestamp: _self.timestamp,
  };
}
