import 'package:json_annotation/json_annotation.dart';

part 'hairstyle.g.dart';

@JsonSerializable()
class Hairstyle {
  final int id;
  final String name;
  final String? image;
  final double price;
  final bool isActive;
  final DateTime createdAt;
  final int lengthId;
  final String lengthName;
  final int genderId;
  final String genderName;

  Hairstyle({
    this.id = 0,
    this.name = '',
    this.image,
    this.price = 0.0,
    this.isActive = true,
    required this.createdAt,
    this.lengthId = 0,
    this.lengthName = '',
    this.genderId = 0,
    this.genderName = '',
  });

  factory Hairstyle.fromJson(Map<String, dynamic> json) =>
      _$HairstyleFromJson(json);
  Map<String, dynamic> toJson() => _$HairstyleToJson(this);
}

