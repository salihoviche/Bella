import 'package:bella_client_mobile/model/facial_hair.dart';
import 'package:bella_client_mobile/providers/base_provider.dart';

class FacialHairProvider extends BaseProvider<FacialHair> {
  FacialHairProvider() : super('FacialHair');

  @override
  FacialHair fromJson(dynamic json) {
    return FacialHair.fromJson(json as Map<String, dynamic>);
  }
}

