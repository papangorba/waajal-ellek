import 'dart:convert';
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
  static const appStatus = "/api/mobile/app/status";
  static const userAccess = "/api/mobile/user/access";


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

  // ─── Requêtes génériques ──────────────────────────────────────────────────

  /// GET sans authentification
  static Future<http.Response> get(String endpoint) async {
    final client = getHttpClient();
    try {
      return await client
          .get(uri(endpoint), headers: defaultHeaders)
          .timeout(const Duration(seconds: 10));
    } finally {
      client.close();
    }
  }

  /// GET avec token
  static Future<http.Response> getAuth(String endpoint, String token) async {
    final client = getHttpClient();
    try {
      return await client
          .get(uri(endpoint), headers: getauthHeaders(token))
          .timeout(const Duration(seconds: 10));
    } finally {
      client.close();
    }
  }

  /// POST sans authentification
  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final client = getHttpClient();
    try {
      return await client
          .post(
        uri(endpoint),
        headers: defaultHeaders,
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 10));
    } finally {
      client.close();
    }
  }

  /// POST avec token
  static Future<http.Response> postAuth(
      String endpoint, String token, Map<String, dynamic> body) async {
    final client = getHttpClient();
    try {
      return await client
          .post(
        uri(endpoint),
        headers: getauthHeaders(token),
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 10));
    } finally {
      client.close();
    }
  }


}