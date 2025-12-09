// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facial_hair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacialHair _$FacialHairFromJson(Map<String, dynamic> json) => FacialHair(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  image: json['image'] as String?,
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$FacialHairToJson(FacialHair instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'price': instance.price,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
