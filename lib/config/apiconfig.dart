import 'dart:io' show Platform, HttpClient, X509Certificate;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "https://we-api.diamonotech.com";
    } else if (Platform.isAndroid) {
      return "https://we-api.diamonotech.com";
    } else {
      return "https://we-api.diamonotech.com";
    }
  }

  //les endpoints
  static const cotisations = "/api/mobile/user/cotisations";
  static const pensions = "/api/mobile/user/pensions";
  static const transaction_recent = "/api/mobile/user/recent-transactions";
  static const dashboard = "/api/mobile/user/dashboard-stats";
  static const login = "/api/mobile/auth/login";
  static const profile = "/api/mobile/user-profile";
  static const logout = "/api/mobile/auth/logout";

  //verification du certificat
  static http.Client getHttpClient() {
    if (kIsWeb) {
      return http.Client();
    }

    final ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (host == 'we-api.diamonotech.com') {
          print(' Certificat SSL accepté pour: $host');
          return true;
        }
        print(' Certificat SSL rejeté pour: $host');
        return false;
      };

    return IOClient(ioClient);
  }

  //header par defaut
  static Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static Map<String, String> getauthHeaders(String token) {
    return {
      ...defaultHeaders,
      "Authorization": "Bearer $token",
    };
  }

  static Uri uri(String endpoint) {
    return Uri.parse("$baseUrl$endpoint");
  }
}