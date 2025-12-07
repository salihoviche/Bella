import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bella_desktop/model/analytics.dart';
import 'package:bella_desktop/providers/auth_provider.dart';

class AnalyticsProvider with ChangeNotifier {
  static String? baseUrl;
  AnalyticsResponse? _analytics;
  bool _isLoading = false;
  String? _error;

  AnalyticsProvider() {
    baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5130/",
    );
  }

  AnalyticsResponse? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<AnalyticsResponse?> getAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String cleanBaseUrl = baseUrl!.endsWith('/')
          ? baseUrl!.substring(0, baseUrl!.length - 1)
          : baseUrl!;
      var url = "$cleanBaseUrl/Analytics";
      var uri = Uri.parse(url);
      var headers = _createHeaders();

      var response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception("Request timeout - backend might not be running");
            },
          );

      if (_isValidResponse(response)) {
        var data = jsonDecode(response.body);
        _analytics = AnalyticsResponse.fromJson(data);
        _error = null;
      } else {
        _error = "Failed to fetch analytics";
      }
    } catch (e) {
      if (e.toString().contains("SocketException")) {
        _error = "Cannot connect to backend. Please check if the backend is running.";
      } else if (e.toString().contains("timeout")) {
        _error = "Request timeout. Backend might not be responding.";
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _analytics;
  }

  bool _isValidResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Please check your credentials and try again.");
    } else if (response.statusCode == 404) {
      throw Exception("Analytics endpoint not found. Status: ${response.statusCode}");
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  }

  Map<String, String> _createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    return headers;
  }
}

