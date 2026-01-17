import 'dart:ui';
import 'package:databreeze/databreeze.dart';

class Folder extends BreezeModel<int> with FolderModel {
  String title;
  Color color;

  Folder({
    required this.title,
    required this.color,
  });
}

mixin FolderModel {
  static final blueprint = BreezeModelBlueprint<Folder>.versioned(
    versions: {
      BreezeModelSchemaVersion(
        version: 1,
        name: 'folders',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('title'),
          BreezeModelColumn<Color>('color'),
        },
      ),
    },
    builder: fromRecord,
  );

  static Folder fromRecord(Map<String, dynamic> map) => Folder(
    title: map[title],
    color: map[color],
  );

  static const id = BreezeField('id');
  static const title = BreezeField('title');
  static const color = BreezeField('color');

  // ---

  Folder get _self => this as Folder;

  BreezeModelBlueprint get schema => blueprint;

  Map<String, dynamic> toRecord() => {
    title: _self.title,
    color: _self.color,
  };
}
