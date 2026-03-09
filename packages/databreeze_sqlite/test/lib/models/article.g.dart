// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// BreezeModelGenerator
// **************************************************************************

mixin ArticleModel {
  static final blueprint = BreezeModelBlueprint<Article>(
    name: 'articles',
    columns: {
      // id
      BreezeModelColumn<int>('id', isPrimaryKey: true),

      // title
      BreezeModelColumn<String>('title'),

      // text
      BreezeModelColumn<String>('text'),
    },

    relations: {
      BreezeModelRelation<ArticleTag>.hasMany(
        name: 'tags',
        foreignKey: 'article_id',
      ),
    },
    builder: ArticleModel.fromRecord,
  );

  static Article fromRecord(Map<String, dynamic> map) => Article(
    title: map[ArticleModel.title],
    text: map[ArticleModel.text],
    tags: map['tags'],
  );

  static const id = BreezeField('id');
  static const title = BreezeField('title');
  static const text = BreezeField('text');

  // ---

  Article get _self => this as Article;

  BreezeModelBlueprint get schema => ArticleModel.blueprint;

  Map<String, dynamic> toRecord() => {
    ArticleModel.title: _self.title,
    ArticleModel.text: _self.text,
    'tags': _self.tags,
  };
}
