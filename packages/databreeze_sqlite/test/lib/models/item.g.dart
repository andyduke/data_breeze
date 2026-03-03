// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin ItemModel {
  static final blueprint = BreezeModelBlueprint<Item>(
    name: 'items',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // name
      BreezeModelColumn<String>('name'),

      // category
      BreezeModelColumn<ItemCategory?>('category_id'),
    },
    builder: ItemModel.fromRecord,
  );

  static Item fromRecord(Map<String, dynamic> map) =>
      Item(name: map[ItemModel.name], category: map[ItemModel.category]);

  static const id = BreezeField('id');
  static const name = BreezeField('name');
  static const category = BreezeField('category_id');

  // ---

  Item get _self => this as Item;

  BreezeModelBlueprint get schema => ItemModel.blueprint;

  Map<String, dynamic> toRecord() => {
    ItemModel.name: _self.name,
    ItemModel.category: _self.category,
  };
}
