// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: (json['id'] as num?)?.toInt() ?? 0,
  finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
  appointmentDate: DateTime.parse(json['appointmentDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userName: json['userName'] as String? ?? '',
  hairdresserId: (json['hairdresserId'] as num?)?.toInt() ?? 0,
  hairdresserName: json['hairdresserName'] as String? ?? '',
  statusId: (json['statusId'] as num?)?.toInt() ?? 0,
  statusName: json['statusName'] as String? ?? '',
  hairstyleId: (json['hairstyleId'] as num?)?.toInt(),
  hairstyleName: json['hairstyleName'] as String?,
  hairstylePrice: (json['hairstylePrice'] as num?)?.toDouble(),
  hairstyleImage: json['hairstyleImage'] as String?,
  facialHairId: (json['facialHairId'] as num?)?.toInt(),
  facialHairName: json['facialHairName'] as String?,
  facialHairPrice: (json['facialHairPrice'] as num?)?.toDouble(),
  facialHairImage: json['facialHairImage'] as String?,
  dyingId: (json['dyingId'] as num?)?.toInt(),
  dyingName: json['dyingName'] as String?,
  dyingHexCode: json['dyingHexCode'] as String?,
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'finalPrice': instance.finalPrice,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
      'userId': instance.userId,
      'userName': instance.userName,
      'hairdresserId': instance.hairdresserId,
      'hairdresserName': instance.hairdresserName,
      'statusId': instance.statusId,
      'statusName': instance.statusName,
      'hairstyleId': instance.hairstyleId,
      'hairstyleName': instance.hairstyleName,
      'hairstylePrice': instance.hairstylePrice,
      'hairstyleImage': instance.hairstyleImage,
      'facialHairId': instance.facialHairId,
      'facialHairName': instance.facialHairName,
      'facialHairPrice': instance.facialHairPrice,
      'facialHairImage': instance.facialHairImage,
      'dyingId': instance.dyingId,
      'dyingName': instance.dyingName,
      'dyingHexCode': instance.dyingHexCode,
    };
