// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: (json['id'] as num?)?.toInt() ?? 0,
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
  totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  orderId: (json['orderId'] as num?)?.toInt() ?? 0,
  productId: (json['productId'] as num?)?.toInt() ?? 0,
  productName: json['productName'] as String? ?? '',
  productPicture: json['productPicture'] as String?,
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'totalPrice': instance.totalPrice,
  'createdAt': instance.createdAt.toIso8601String(),
  'orderId': instance.orderId,
  'productId': instance.productId,
  'productName': instance.productName,
  'productPicture': instance.productPicture,
};
