import 'package:bella_hairdresser_mobile/model/facial_hair.dart';
import 'package:bella_hairdresser_mobile/providers/base_provider.dart';

class FacialHairProvider extends BaseProvider<FacialHair> {
  FacialHairProvider() : super('FacialHair');

  @override
  FacialHair fromJson(dynamic json) {
    return FacialHair.fromJson(json as Map<String, dynamic>);
  }
}

