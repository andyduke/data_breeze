// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_category.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin ItemCategoryModel {
  static final blueprint = BreezeModelBlueprint<ItemCategory>(
    name: 'item_categories',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // name
      BreezeModelColumn<String>('name'),
    },

    builder: ItemCategoryModel.fromRecord,
  );

  static ItemCategory fromRecord(Map<String, dynamic> map) =>
      ItemCategory(name: map[ItemCategoryModel.name]);

  static const id = BreezeField('id');
  static const name = BreezeField('name');

  // ---

  ItemCategory get _self => this as ItemCategory;

  BreezeModelBlueprint get schema => ItemCategoryModel.blueprint;

  Map<String, dynamic> toRecord() => {ItemCategoryModel.name: _self.name};
}
