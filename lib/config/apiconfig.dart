import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/io_client.dart';

class ApiConfig {

  // Base URL de l'API
  static String get baseUrl {
    if (kIsWeb) {
      return "https://we-api.diamonotech.com";
    } else if (Platform.isAndroid) {
      return "https://we-api.diamonotech.com";
    } else if (Platform.isIOS) {
      return "https://we-api.diamonotech.com";
    } else {
      return "https://we-api.diamonotech.com";
    }
  }

  // Endpoints API
  static const cotisations = "/api/mobile/user/cotisations";
  static const pensions = "/api/mobile/user/pensions";
  static const transaction_recent = "/api/mobile/user/recent-transactions";
  static const dashboard = "/api/mobile/user/dashboard-stats";
  static const login = "/api/mobile/auth/login";
  static const profile = "/api/mobile/user-profile";
  static const logout = "/api/mobile/auth/logout";

  // Client HTTP normal
  //static http.Client getHttpClient() {
 //   return http.Client();
 // }

  static http.Client getHttpClient() {
    final httpClient = HttpClient(
      context: SecurityContext.defaultContext,
    );

    // Utilise les certificats du système Android
    httpClient.badCertificateCallback = (cert, host, port) {
      // Log pour debug uniquement — retirer en prod
      print('Cert issuer: ${cert.issuer}');
      print('Cert subject: ${cert.subject}');
      return false;
    };

    return IOClient(httpClient);
  }


  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // Headers avec authentification
  static Map<String, String> getauthHeaders(String token) {
    return {
      ...defaultHeaders,
      "Authorization": "Bearer $token",
    };
  }

  // Générer une URI complète
  static Uri uri(String endpoint) {
    return Uri.parse("$baseUrl$endpoint");
  }

}