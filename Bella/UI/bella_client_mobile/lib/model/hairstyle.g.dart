// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hairstyle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hairstyle _$HairstyleFromJson(Map<String, dynamic> json) => Hairstyle(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  image: json['image'] as String?,
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lengthId: (json['lengthId'] as num?)?.toInt() ?? 0,
  lengthName: json['lengthName'] as String? ?? '',
  genderId: (json['genderId'] as num?)?.toInt() ?? 0,
  genderName: json['genderName'] as String? ?? '',
);

Map<String, dynamic> _$HairstyleToJson(Hairstyle instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image': instance.image,
  'price': instance.price,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'lengthId': instance.lengthId,
  'lengthName': instance.lengthName,
  'genderId': instance.genderId,
  'genderName': instance.genderName,
};
