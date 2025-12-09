// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  id: (json['id'] as num?)?.toInt() ?? 0,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  cartId: (json['cartId'] as num?)?.toInt() ?? 0,
  productId: (json['productId'] as num?)?.toInt() ?? 0,
  productName: json['productName'] as String? ?? '',
  productPrice: (json['productPrice'] as num?)?.toDouble() ?? 0.0,
  productPicture: json['productPicture'] as String?,
  totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'quantity': instance.quantity,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'cartId': instance.cartId,
  'productId': instance.productId,
  'productName': instance.productName,
  'productPrice': instance.productPrice,
  'productPicture': instance.productPicture,
  'totalPrice': instance.totalPrice,
};
