import 'package:bella_client_mobile/model/hairstyle.dart';
import 'package:bella_client_mobile/providers/base_provider.dart';

class HairstyleProvider extends BaseProvider<Hairstyle> {
  HairstyleProvider() : super('Hairstyle');

  @override
  Hairstyle fromJson(dynamic json) {
    return Hairstyle.fromJson(json as Map<String, dynamic>);
  }
}

