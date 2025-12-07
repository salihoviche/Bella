// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num?)?.toInt() ?? 0,
  orderNumber: json['orderNumber'] as String? ?? '',
  totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userFullName: json['userFullName'] as String? ?? '',
  userImage: json['userImage'] as String?,
  orderItems:
      (json['orderItems'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'orderNumber': instance.orderNumber,
  'totalAmount': instance.totalAmount,
  'createdAt': instance.createdAt.toIso8601String(),
  'isActive': instance.isActive,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'userImage': instance.userImage,
  'orderItems': instance.orderItems,
  'totalItems': instance.totalItems,
};
