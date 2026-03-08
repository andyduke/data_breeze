import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'article_tag.g.dart';

@BzModel(
  name: 'article_tags',
)
class ArticleTag extends BreezeModel<int> with ArticleTagModel {
  String name;

  ArticleTag({
    required this.name,
  });
}
