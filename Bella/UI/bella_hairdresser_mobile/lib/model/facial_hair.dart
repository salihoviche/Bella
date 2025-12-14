import 'package:json_annotation/json_annotation.dart';

part 'facial_hair.g.dart';

@JsonSerializable()
class FacialHair {
  final int id;
  final String name;
  final String? image;
  final double price;
  final bool isActive;
  final DateTime createdAt;

  FacialHair({
    this.id = 0,
    this.name = '',
    this.image,
    this.price = 0.0,
    this.isActive = true,
    required this.createdAt,
  });

  factory FacialHair.fromJson(Map<String, dynamic> json) =>
      _$FacialHairFromJson(json);
  Map<String, dynamic> toJson() => _$FacialHairToJson(this);
}

