import 'package:bella_desktop/model/hairstyle.dart';
import 'package:bella_desktop/providers/base_provider.dart';

class HairstyleProvider extends BaseProvider<Hairstyle> {
  HairstyleProvider() : super('Hairstyle');

  @override
  Hairstyle fromJson(dynamic json) {
    return Hairstyle.fromJson(json as Map<String, dynamic>);
  }
}

