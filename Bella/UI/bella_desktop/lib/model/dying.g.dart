// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dying.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dying _$DyingFromJson(Map<String, dynamic> json) => Dying(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  hexCode: json['hexCode'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DyingToJson(Dying instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'hexCode': instance.hexCode,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
};
