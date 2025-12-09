// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'length.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Length _$LengthFromJson(Map<String, dynamic> json) => Length(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  image: json['image'] as String?,
);

Map<String, dynamic> _$LengthToJson(Length instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image': instance.image,
};
