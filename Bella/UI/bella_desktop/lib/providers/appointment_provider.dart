import 'dart:convert';
import 'package:bella_desktop/model/appointment.dart';
import 'package:bella_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class AppointmentProvider extends BaseProvider<Appointment> {
  AppointmentProvider() : super('Appointment');

  @override
  Appointment fromJson(dynamic json) {
    return Appointment.fromJson(json as Map<String, dynamic>);
  }

  // Cancel appointment endpoint
  Future<Appointment> cancelAppointment(int id) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/cancel";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  // Complete appointment endpoint
  Future<Appointment> completeAppointment(int id) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/complete";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
}
