// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  picture: json['picture'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
  categoryName: json['categoryName'] as String? ?? '',
  manufacturerId: (json['manufacturerId'] as num?)?.toInt() ?? 0,
  manufacturerName: json['manufacturerName'] as String? ?? '',
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'picture': instance.picture,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'manufacturerId': instance.manufacturerId,
  'manufacturerName': instance.manufacturerName,
};
