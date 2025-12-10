import 'package:bella_client_mobile/model/manufacturer.dart';
import 'package:bella_client_mobile/providers/base_provider.dart';

class ManufacturerProvider extends BaseProvider<Manufacturer> {
  ManufacturerProvider() : super("Manufacturer");

  @override
  Manufacturer fromJson(dynamic json) {
    return Manufacturer.fromJson(json);
  }
}

