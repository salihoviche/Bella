// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cart _$CartFromJson(Map<String, dynamic> json) => Cart(
  id: (json['id'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userFullName: json['userFullName'] as String? ?? '',
  cartItems:
      (json['cartItems'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
  totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$CartToJson(Cart instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'isActive': instance.isActive,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'cartItems': instance.cartItems,
  'totalItems': instance.totalItems,
  'totalAmount': instance.totalAmount,
};
