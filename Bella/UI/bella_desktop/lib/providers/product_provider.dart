import 'package:bella_desktop/model/product.dart';
import 'package:bella_desktop/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(dynamic json) {
    return Product.fromJson(json);
  }
}

