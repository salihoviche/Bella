import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class ReviewAppointment {
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
  final int? facialHairId;
  final String? facialHairName;
  final double? facialHairPrice;
  final int? dyingId;
  final String? dyingName;
  final String? dyingHexCode;

  const ReviewAppointment({
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
    this.facialHairId,
    this.facialHairName,
    this.facialHairPrice,
    this.dyingId,
    this.dyingName,
    this.dyingHexCode,
  });

  factory ReviewAppointment.fromJson(Map<String, dynamic> json) => _$ReviewAppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewAppointmentToJson(this);
}

@JsonSerializable()
class Review {
  final int id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final bool isActive;
  final int userId;
  final String userName;
  final String userFullName;
  final String hairdresserFullName;
  final int appointmentId;
  final ReviewAppointment? appointment;

  const Review({
    this.id = 0,
    this.rating = 0,
    this.comment,
    required this.createdAt,
    this.isActive = true,
    this.userId = 0,
    this.userName = '',
    this.userFullName = '',
    this.hairdresserFullName = '',
    this.appointmentId = 0,
    this.appointment,
  });

  // Helper getters for backward compatibility and wellness service info
  int get wellnessServiceId {
    if (appointment?.hairstyleId != null) return appointment!.hairstyleId!;
    if (appointment?.facialHairId != null) return appointment!.facialHairId!;
    if (appointment?.dyingId != null) return appointment!.dyingId!;
    return 0;
  }

  String get wellnessServiceName {
    if (appointment?.hairstyleName != null && appointment!.hairstyleName!.isNotEmpty) {
      return appointment!.hairstyleName!;
    }
    if (appointment?.facialHairName != null && appointment!.facialHairName!.isNotEmpty) {
      return appointment!.facialHairName!;
    }
    if (appointment?.dyingName != null && appointment!.dyingName!.isNotEmpty) {
      return appointment!.dyingName!;
    }
    return '';
  }

  String? get wellnessServiceImage {
    // Wellness service images would need to be added to the backend if needed
    return null;
  }

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
