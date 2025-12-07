import 'package:json_annotation/json_annotation.dart';

part 'manufacturer.g.dart';

@JsonSerializable()
class Manufacturer {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  Manufacturer({
    this.id = 0,
    this.name = '',
    this.description,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Manufacturer.fromJson(Map<String, dynamic> json) =>
      _$ManufacturerFromJson(json);
  Map<String, dynamic> toJson() => _$ManufacturerToJson(this);
}

