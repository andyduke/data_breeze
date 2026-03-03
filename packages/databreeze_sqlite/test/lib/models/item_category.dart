import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

part 'item_category.g.dart';

@BzModel(
  name: 'item_categories',
)
class ItemCategory extends BreezeModel<int> with ItemCategoryModel {
  String name;

  ItemCategory({
    required this.name,
  });
}
