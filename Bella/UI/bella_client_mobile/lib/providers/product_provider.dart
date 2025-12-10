import 'dart:convert';
import 'package:bella_client_mobile/model/product.dart';
import 'package:bella_client_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(dynamic json) {
    return Product.fromJson(json);
  }

  Future<List<Product>> getRecommendations(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/recommend/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return [];
      var data = jsonDecode(response.body);
      return List<Product>.from(data.map((e) => fromJson(e)));
    } else {
      throw Exception("Unknown error");
    }
  }
}

