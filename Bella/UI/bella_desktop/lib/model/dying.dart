import 'package:json_annotation/json_annotation.dart';

part 'dying.g.dart';

@JsonSerializable()
class Dying {
  final int id;
  final String name;
  final String? hexCode;
  final bool isActive;
  final DateTime createdAt;

  Dying({
    this.id = 0,
    this.name = '',
    this.hexCode,
    this.isActive = true,
    required this.createdAt,
  });

  factory Dying.fromJson(Map<String, dynamic> json) =>
      _$DyingFromJson(json);
  Map<String, dynamic> toJson() => _$DyingToJson(this);
}

