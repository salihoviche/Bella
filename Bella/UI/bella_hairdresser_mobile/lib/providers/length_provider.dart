import 'package:bella_hairdresser_mobile/model/length.dart';
import 'package:bella_hairdresser_mobile/providers/base_provider.dart';

class LengthProvider extends BaseProvider<Length> {
  LengthProvider() : super('Length');

  @override
  Length fromJson(dynamic json) {
    return Length.fromJson(json as Map<String, dynamic>);
  }
}

