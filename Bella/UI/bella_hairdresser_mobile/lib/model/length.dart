import 'package:json_annotation/json_annotation.dart';

part 'length.g.dart';

@JsonSerializable()
class Length {
  final int id;
  final String name;
  final String? image;

  const Length({
    this.id = 0,
    this.name = '',
    this.image,
  });

  factory Length.fromJson(Map<String, dynamic> json) => _$LengthFromJson(json);
  Map<String, dynamic> toJson() => _$LengthToJson(this);
}

