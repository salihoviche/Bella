import 'dart:convert';
import 'package:bella_client_mobile/model/cart.dart';
import 'package:bella_client_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class CartProvider extends BaseProvider<Cart> {
  CartProvider() : super("Cart");

  @override
  Cart fromJson(dynamic json) {
    return Cart.fromJson(json);
  }

  /// Get cart by user ID
  Future<Cart?> getByUserId(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);
      if (response.statusCode == 404) {
        return null;
      }
      if (isValidResponse(response)) {
        if (response.body.isEmpty) return null;
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Unknown error");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get or create cart for user
  Future<Cart> getOrCreateCart(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId/get-or-create";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to get or create cart");
    }
  }

  /// Add item to cart
  Future<Cart> addItemToCart(int userId, int productId, int quantity) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId/add-item";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({
      'productId': productId,
      'quantity': quantity,
    });

    var response = await http.post(uri, headers: headers, body: body);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      notifyListeners(); // Notify listeners when cart is updated
      return fromJson(data);
    } else {
      throw Exception("Failed to add item to cart");
    }
  }

  /// Update item quantity in cart
  Future<Cart> updateItemQuantity(int userId, int productId, int quantity) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId/update-item";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({
      'productId': productId,
      'quantity': quantity,
    });

    var response = await http.put(uri, headers: headers, body: body);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      notifyListeners(); // Notify listeners when cart is updated
      return fromJson(data);
    } else {
      throw Exception("Failed to update item quantity");
    }
  }

  /// Remove item from cart
  Future<Cart> removeItemFromCart(int userId, int productId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId/remove-item/$productId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      notifyListeners(); // Notify listeners when cart is updated
      return fromJson(data);
    } else {
      throw Exception("Failed to remove item from cart");
    }
  }

  /// Clear cart
  Future<Cart> clearCart(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId/clear";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      notifyListeners(); // Notify listeners when cart is updated
      return fromJson(data);
    } else {
      throw Exception("Failed to clear cart");
    }
  }

  /// Get cart summary
  Future<Map<String, dynamic>> getCartSummary(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId/summary";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Failed to get cart summary");
    }
  }
}

