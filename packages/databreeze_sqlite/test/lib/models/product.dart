import 'package:databreeze/databreeze.dart';

final class ProductColumns {
  static const id = 'id';
  static const name = 'name';
  static const price = 'price';
}

class Product extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint<Product>(
    builder: Product.fromRecord,
    name: 'products',
    // key: 'id',
    columns: {
      BreezeModelColumn<int>(ProductColumns.id, isPrimaryKey: true),
      BreezeModelColumn<String>(ProductColumns.name),
      BreezeModelColumn<int?>(ProductColumns.price),
    },
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;
  int? price;

  Product({
    required this.name,
    this.price,
  });

  factory Product.fromRecord(BreezeDataRecord record) => Product(
    name: record[ProductColumns.name],
    price: record[ProductColumns.price],
  );

  @override
  Map<String, dynamic> toRecord() => {
    ProductColumns.name: name,
    ProductColumns.price: price,
  };

  @override
  String toString() =>
      '''Product(
  id: $id,
  name: $name,
  price: $price
)''';
}
