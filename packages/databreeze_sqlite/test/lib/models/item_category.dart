import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

// import 'item.dart';

part 'item_category.g.dart';

@BzModel(
  name: 'item_categories',
)
class ItemCategory extends BreezeModel<int> with ItemCategoryModel {
  String name;

  // @BzColumn(name: 'category_id')
  // TODO: @BzReference(foreign_key: 'category_id')
  // List<Item> items;

  ItemCategory({
    required this.name,
    // this.items = const [],
  });
}
