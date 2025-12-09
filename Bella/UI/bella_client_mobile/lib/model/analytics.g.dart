// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsResponse _$AnalyticsResponseFromJson(
  Map<String, dynamic> json,
) => AnalyticsResponse(
  top3Products: (json['top3Products'] as List<dynamic>)
      .map(
        (e) => TopProductAnalyticsResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  top3Hairstyles: (json['top3Hairstyles'] as List<dynamic>)
      .map(
        (e) =>
            TopHairstyleAnalyticsResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  top3FacialHairs: (json['top3FacialHairs'] as List<dynamic>)
      .map(
        (e) =>
            TopFacialHairAnalyticsResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  top3DyingColors: (json['top3DyingColors'] as List<dynamic>)
      .map((e) => TopDyingAnalyticsResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AnalyticsResponseToJson(AnalyticsResponse instance) =>
    <String, dynamic>{
      'top3Products': instance.top3Products,
      'top3Hairstyles': instance.top3Hairstyles,
      'top3FacialHairs': instance.top3FacialHairs,
      'top3DyingColors': instance.top3DyingColors,
    };

TopProductAnalyticsResponse _$TopProductAnalyticsResponseFromJson(
  Map<String, dynamic> json,
) => TopProductAnalyticsResponse(
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  productImage: json['productImage'] as String?,
  totalQuantitySold: (json['totalQuantitySold'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
);

Map<String, dynamic> _$TopProductAnalyticsResponseToJson(
  TopProductAnalyticsResponse instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'productImage': instance.productImage,
  'totalQuantitySold': instance.totalQuantitySold,
  'totalRevenue': instance.totalRevenue,
};

TopHairstyleAnalyticsResponse _$TopHairstyleAnalyticsResponseFromJson(
  Map<String, dynamic> json,
) => TopHairstyleAnalyticsResponse(
  hairstyleId: (json['hairstyleId'] as num).toInt(),
  hairstyleName: json['hairstyleName'] as String,
  hairstyleImage: json['hairstyleImage'] as String?,
  totalAppointments: (json['totalAppointments'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
);

Map<String, dynamic> _$TopHairstyleAnalyticsResponseToJson(
  TopHairstyleAnalyticsResponse instance,
) => <String, dynamic>{
  'hairstyleId': instance.hairstyleId,
  'hairstyleName': instance.hairstyleName,
  'hairstyleImage': instance.hairstyleImage,
  'totalAppointments': instance.totalAppointments,
  'totalRevenue': instance.totalRevenue,
};

TopFacialHairAnalyticsResponse _$TopFacialHairAnalyticsResponseFromJson(
  Map<String, dynamic> json,
) => TopFacialHairAnalyticsResponse(
  facialHairId: (json['facialHairId'] as num).toInt(),
  facialHairName: json['facialHairName'] as String,
  facialHairImage: json['facialHairImage'] as String?,
  totalAppointments: (json['totalAppointments'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
);

Map<String, dynamic> _$TopFacialHairAnalyticsResponseToJson(
  TopFacialHairAnalyticsResponse instance,
) => <String, dynamic>{
  'facialHairId': instance.facialHairId,
  'facialHairName': instance.facialHairName,
  'facialHairImage': instance.facialHairImage,
  'totalAppointments': instance.totalAppointments,
  'totalRevenue': instance.totalRevenue,
};

TopDyingAnalyticsResponse _$TopDyingAnalyticsResponseFromJson(
  Map<String, dynamic> json,
) => TopDyingAnalyticsResponse(
  dyingId: (json['dyingId'] as num).toInt(),
  dyingName: json['dyingName'] as String,
  dyingHexCode: json['dyingHexCode'] as String?,
  totalAppointments: (json['totalAppointments'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
);

Map<String, dynamic> _$TopDyingAnalyticsResponseToJson(
  TopDyingAnalyticsResponse instance,
) => <String, dynamic>{
  'dyingId': instance.dyingId,
  'dyingName': instance.dyingName,
  'dyingHexCode': instance.dyingHexCode,
  'totalAppointments': instance.totalAppointments,
  'totalRevenue': instance.totalRevenue,
};
