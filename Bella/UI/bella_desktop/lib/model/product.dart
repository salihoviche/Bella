import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final double price;
  final String? picture;
  final bool isActive;
  final DateTime createdAt;
  final int categoryId;
  final String categoryName;
  final int manufacturerId;
  final String manufacturerName;

  Product({
    this.id = 0,
    this.name = '',
    this.price = 0.0,
    this.picture,
    this.isActive = true,
    required this.createdAt,
    this.categoryId = 0,
    this.categoryName = '',
    this.manufacturerId = 0,
    this.manufacturerName = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

