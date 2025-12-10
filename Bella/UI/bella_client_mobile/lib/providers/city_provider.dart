import 'package:bella_client_mobile/model/city.dart';
import 'package:bella_client_mobile/providers/base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(dynamic json) {
    return City.fromJson(json);
  }
}
