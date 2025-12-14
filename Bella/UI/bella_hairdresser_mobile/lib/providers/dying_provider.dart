import 'package:bella_hairdresser_mobile/model/dying.dart';
import 'package:bella_hairdresser_mobile/providers/base_provider.dart';

class DyingProvider extends BaseProvider<Dying> {
  DyingProvider() : super('Dying');

  @override
  Dying fromJson(dynamic json) {
    return Dying.fromJson(json as Map<String, dynamic>);
  }
}

