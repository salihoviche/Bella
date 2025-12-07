import 'package:json_annotation/json_annotation.dart';
import 'package:bella_desktop/model/order_item.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final int id;
  final String orderNumber;
  final double totalAmount;
  final DateTime createdAt;
  final bool isActive;
  final int userId;
  final String userFullName;
  final String? userImage;
  final List<OrderItem> orderItems;
  final int totalItems;

  Order({
    this.id = 0,
    this.orderNumber = '',
    this.totalAmount = 0.0,
    required this.createdAt,
    this.isActive = true,
    this.userId = 0,
    this.userFullName = '',
    this.userImage,
    this.orderItems = const [],
    this.totalItems = 0,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

