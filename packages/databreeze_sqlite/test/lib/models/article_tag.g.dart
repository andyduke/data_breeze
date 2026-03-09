// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_tag.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin ArticleTagModel {
  static final blueprint = BreezeModelBlueprint<ArticleTag>(
    name: 'article_tags',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // name
      BreezeModelColumn<String>('name'),
    },

    builder: ArticleTagModel.fromRecord,
  );

  static ArticleTag fromRecord(Map<String, dynamic> map) =>
      ArticleTag(name: map[ArticleTagModel.name]);

  static const id = BreezeField('id');
  static const name = BreezeField('name');

  // ---

  ArticleTag get _self => this as ArticleTag;

  BreezeModelBlueprint get schema => ArticleTagModel.blueprint;

  Map<String, dynamic> toRecord() => {ArticleTagModel.name: _self.name};
}
