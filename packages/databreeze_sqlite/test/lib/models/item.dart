import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

import 'item_category.dart';

part 'item.g.dart';

@BzModel(
  name: 'items',
)
class Item extends BreezeModel<int> with ItemModel {
  String name;

  // @BzColumn(name: 'category_id')
  @BzRelationship.belongsTo(
    name: 'category',
    sourceKey: BreezeRelationTypedKey('category_id', int),
  )
  ItemCategory? category;

  Item({
    required this.name,
    this.category,
  });
}
