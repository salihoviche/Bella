import 'dart:convert';
import 'package:bella_client_mobile/model/order.dart';
import 'package:bella_client_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(dynamic json) {
    return Order.fromJson(json);
  }

  /// Create order from cart
  Future<Order> createOrderFromCart(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId/create-from-cart";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to create order from cart");
    }
  }
}

