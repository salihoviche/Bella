// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewAppointment _$ReviewAppointmentFromJson(Map<String, dynamic> json) =>
    ReviewAppointment(
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
      facialHairId: (json['facialHairId'] as num?)?.toInt(),
      facialHairName: json['facialHairName'] as String?,
      facialHairPrice: (json['facialHairPrice'] as num?)?.toDouble(),
      dyingId: (json['dyingId'] as num?)?.toInt(),
      dyingName: json['dyingName'] as String?,
      dyingHexCode: json['dyingHexCode'] as String?,
    );

Map<String, dynamic> _$ReviewAppointmentToJson(ReviewAppointment instance) =>
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
      'facialHairId': instance.facialHairId,
      'facialHairName': instance.facialHairName,
      'facialHairPrice': instance.facialHairPrice,
      'dyingId': instance.dyingId,
      'dyingName': instance.dyingName,
      'dyingHexCode': instance.dyingHexCode,
    };

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toInt() ?? 0,
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userName: json['userName'] as String? ?? '',
  userFullName: json['userFullName'] as String? ?? '',
  hairdresserFullName: json['hairdresserFullName'] as String? ?? '',
  appointmentId: (json['appointmentId'] as num?)?.toInt() ?? 0,
  appointment: json['appointment'] == null
      ? null
      : ReviewAppointment.fromJson(json['appointment'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'isActive': instance.isActive,
  'userId': instance.userId,
  'userName': instance.userName,
  'userFullName': instance.userFullName,
  'hairdresserFullName': instance.hairdresserFullName,
  'appointmentId': instance.appointmentId,
  'appointment': instance.appointment,
};
