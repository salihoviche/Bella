import 'package:json_annotation/json_annotation.dart';

part 'hairdresser_analytics.g.dart';

@JsonSerializable()
class HairdresserAnalyticsResponse {
  @JsonKey(name: 'hairdresserId')
  final int hairdresserId;

  @JsonKey(name: 'year')
  final int year;

  @JsonKey(name: 'month')
  final int month;

  @JsonKey(name: 'totalAppointments')
  final int totalAppointments;

  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  @JsonKey(name: 'dailyData')
  final List<DailyAnalyticsData> dailyData;

  HairdresserAnalyticsResponse({
    required this.hairdresserId,
    required this.year,
    required this.month,
    required this.totalAppointments,
    required this.totalRevenue,
    required this.dailyData,
  });

  factory HairdresserAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      _$HairdresserAnalyticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HairdresserAnalyticsResponseToJson(this);
}

@JsonSerializable()
class DailyAnalyticsData {
  @JsonKey(name: 'date')
  final DateTime date;

  @JsonKey(name: 'dayNumber')
  final int dayNumber;

  @JsonKey(name: 'appointmentCount')
  final int appointmentCount;

  @JsonKey(name: 'revenue')
  final double revenue;

  DailyAnalyticsData({
    required this.date,
    required this.dayNumber,
    required this.appointmentCount,
    required this.revenue,
  });

  factory DailyAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$DailyAnalyticsDataFromJson(json);

  Map<String, dynamic> toJson() => _$DailyAnalyticsDataToJson(this);
}

