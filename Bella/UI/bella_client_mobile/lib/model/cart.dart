import 'package:json_annotation/json_annotation.dart';
import 'package:bella_client_mobile/model/cart_item.dart';

part 'cart.g.dart';

@JsonSerializable()
class Cart {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final bool isActive;
  final int userId;
  final String userFullName;
  final List<CartItem> cartItems;
  final int totalItems;
  final double totalAmount;

  Cart({
    this.id = 0,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.isActive = true,
    this.userId = 0,
    this.userFullName = '',
    this.cartItems = const [],
    this.totalItems = 0,
    this.totalAmount = 0.0,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);
}

