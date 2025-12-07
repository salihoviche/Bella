import 'package:json_annotation/json_annotation.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  final int id;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;
  final int orderId;
  final int productId;
  final String productName;
  final String? productPicture;

  OrderItem({
    this.id = 0,
    this.quantity = 0,
    this.unitPrice = 0.0,
    this.totalPrice = 0.0,
    required this.createdAt,
    this.orderId = 0,
    this.productId = 0,
    this.productName = '',
    this.productPicture,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

