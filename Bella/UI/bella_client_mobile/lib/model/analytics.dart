import 'package:json_annotation/json_annotation.dart';

part 'analytics.g.dart';

@JsonSerializable()
class AnalyticsResponse {
  @JsonKey(name: 'top3Products')
  final List<TopProductAnalyticsResponse> top3Products;

  @JsonKey(name: 'top3Hairstyles')
  final List<TopHairstyleAnalyticsResponse> top3Hairstyles;

  @JsonKey(name: 'top3FacialHairs')
  final List<TopFacialHairAnalyticsResponse> top3FacialHairs;

  @JsonKey(name: 'top3DyingColors')
  final List<TopDyingAnalyticsResponse> top3DyingColors;

  AnalyticsResponse({
    required this.top3Products,
    required this.top3Hairstyles,
    required this.top3FacialHairs,
    required this.top3DyingColors,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsResponseToJson(this);
}

@JsonSerializable()
class TopProductAnalyticsResponse {
  @JsonKey(name: 'productId')
  final int productId;

  @JsonKey(name: 'productName')
  final String productName;

  @JsonKey(name: 'productImage')
  final String? productImage;

  @JsonKey(name: 'totalQuantitySold')
  final int totalQuantitySold;

  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  TopProductAnalyticsResponse({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  factory TopProductAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      _$TopProductAnalyticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopProductAnalyticsResponseToJson(this);
}

@JsonSerializable()
class TopHairstyleAnalyticsResponse {
  @JsonKey(name: 'hairstyleId')
  final int hairstyleId;

  @JsonKey(name: 'hairstyleName')
  final String hairstyleName;

  @JsonKey(name: 'hairstyleImage')
  final String? hairstyleImage;

  @JsonKey(name: 'totalAppointments')
  final int totalAppointments;

  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  TopHairstyleAnalyticsResponse({
    required this.hairstyleId,
    required this.hairstyleName,
    this.hairstyleImage,
    required this.totalAppointments,
    required this.totalRevenue,
  });

  factory TopHairstyleAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      _$TopHairstyleAnalyticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopHairstyleAnalyticsResponseToJson(this);
}

@JsonSerializable()
class TopFacialHairAnalyticsResponse {
  @JsonKey(name: 'facialHairId')
  final int facialHairId;

  @JsonKey(name: 'facialHairName')
  final String facialHairName;

  @JsonKey(name: 'facialHairImage')
  final String? facialHairImage;

  @JsonKey(name: 'totalAppointments')
  final int totalAppointments;

  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  TopFacialHairAnalyticsResponse({
    required this.facialHairId,
    required this.facialHairName,
    this.facialHairImage,
    required this.totalAppointments,
    required this.totalRevenue,
  });

  factory TopFacialHairAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      _$TopFacialHairAnalyticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopFacialHairAnalyticsResponseToJson(this);
}

@JsonSerializable()
class TopDyingAnalyticsResponse {
  @JsonKey(name: 'dyingId')
  final int dyingId;

  @JsonKey(name: 'dyingName')
  final String dyingName;

  @JsonKey(name: 'dyingHexCode')
  final String? dyingHexCode;

  @JsonKey(name: 'totalAppointments')
  final int totalAppointments;

  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  TopDyingAnalyticsResponse({
    required this.dyingId,
    required this.dyingName,
    this.dyingHexCode,
    required this.totalAppointments,
    required this.totalRevenue,
  });

  factory TopDyingAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      _$TopDyingAnalyticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopDyingAnalyticsResponseToJson(this);
}

