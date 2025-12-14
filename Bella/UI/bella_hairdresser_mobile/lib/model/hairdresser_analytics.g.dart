// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hairdresser_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HairdresserAnalyticsResponse _$HairdresserAnalyticsResponseFromJson(
  Map<String, dynamic> json,
) => HairdresserAnalyticsResponse(
  hairdresserId: (json['hairdresserId'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  totalAppointments: (json['totalAppointments'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  dailyData: (json['dailyData'] as List<dynamic>)
      .map((e) => DailyAnalyticsData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HairdresserAnalyticsResponseToJson(
  HairdresserAnalyticsResponse instance,
) => <String, dynamic>{
  'hairdresserId': instance.hairdresserId,
  'year': instance.year,
  'month': instance.month,
  'totalAppointments': instance.totalAppointments,
  'totalRevenue': instance.totalRevenue,
  'dailyData': instance.dailyData,
};

DailyAnalyticsData _$DailyAnalyticsDataFromJson(Map<String, dynamic> json) =>
    DailyAnalyticsData(
      date: DateTime.parse(json['date'] as String),
      dayNumber: (json['dayNumber'] as num).toInt(),
      appointmentCount: (json['appointmentCount'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
    );

Map<String, dynamic> _$DailyAnalyticsDataToJson(DailyAnalyticsData instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'dayNumber': instance.dayNumber,
      'appointmentCount': instance.appointmentCount,
      'revenue': instance.revenue,
    };
