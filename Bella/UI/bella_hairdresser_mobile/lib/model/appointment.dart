import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  final int id;
  final double finalPrice;
  final DateTime appointmentDate;
  final DateTime createdAt;
  final bool isActive;
  final int userId;
  final String userName;
  final int hairdresserId;
  final String hairdresserName;
  final int statusId;
  final String statusName;
  final int? hairstyleId;
  final String? hairstyleName;
  final double? hairstylePrice;
  @JsonKey(name: 'hairstyleImage')
  final String? hairstyleImage;
  final int? facialHairId;
  final String? facialHairName;
  final double? facialHairPrice;
  @JsonKey(name: 'facialHairImage')
  final String? facialHairImage;
  final int? dyingId;
  final String? dyingName;
  final String? dyingHexCode;

  Appointment({
    this.id = 0,
    this.finalPrice = 0.0,
    required this.appointmentDate,
    required this.createdAt,
    this.isActive = true,
    this.userId = 0,
    this.userName = '',
    this.hairdresserId = 0,
    this.hairdresserName = '',
    this.statusId = 0,
    this.statusName = '',
    this.hairstyleId,
    this.hairstyleName,
    this.hairstylePrice,
    this.hairstyleImage,
    this.facialHairId,
    this.facialHairName,
    this.facialHairPrice,
    this.facialHairImage,
    this.dyingId,
    this.dyingName,
    this.dyingHexCode,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
