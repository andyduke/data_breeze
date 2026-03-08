import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

import 'article_tag.dart';

part 'article.g.dart';

/*
class Article ... {

  // Belongs to
  @BzRelation(foreignKey: 'category_id')
  List<ArticleTag> tags;

}

static final blueprint = BreezeModelBlueprint<Article>(
  name: 'articles',
  columns: {
    BreezeModelColumn<int>('id', isPrimaryKey: true),
    BreezeModelColumn<String>('title'),
    BreezeModelColumn<String>('text'),
  },

  relations: {
    BreezeModelRelation<ArticleTag>.belongsTo('tags', foreignKey: 'category_id'),
  },

  builder: ArticleModel.fromRecord,
);

*/

@BzModel(
  name: 'articles',
)
class Article extends BreezeModel<int> with ArticleModel {
  String title;

  String text;

  // TODO: Belongs to
  // @BzColumn(name: 'category_id')
  List<ArticleTag> tags;

  Article({
    required this.title,
    required this.text,
    this.tags = const [],
  });
}
