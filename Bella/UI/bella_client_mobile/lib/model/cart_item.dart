import 'package:json_annotation/json_annotation.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  final int id;
  final int quantity;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int cartId;
  final int productId;
  final String productName;
  final double productPrice;
  final String? productPicture; // Base64 encoded image
  final double totalPrice;

  CartItem({
    this.id = 0,
    this.quantity = 1,
    required this.createdAt,
    this.updatedAt,
    this.cartId = 0,
    this.productId = 0,
    this.productName = '',
    this.productPrice = 0.0,
    this.productPicture,
    this.totalPrice = 0.0,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}

