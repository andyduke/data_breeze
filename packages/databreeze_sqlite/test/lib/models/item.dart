import 'package:databreeze/databreeze.dart';
import 'package:databreeze_annotation/databreeze_annotation.dart';

import 'item_category.dart';

part 'item.g.dart';

@BzModel(
  name: 'items',
)
class Item extends BreezeModel<int> with ItemModel {
  String name;

  @BzColumn(name: 'category_id')
  ItemCategory /* ? */ category;

  Item({
    required this.name,
    /* ? */ required this.category,
  });
}
