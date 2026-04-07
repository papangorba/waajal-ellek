import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/apiconfig.dart';
import '../models/app_status_model.dart';
import '../models/user_access_model.dart';

class AppStatusService {

  /// Récupère le statut de l'application depuis l'API réelle.
  static Future<AppStatusModel> getAppStatus() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final installedVersion = packageInfo.version;

    final client = ApiConfig.getHttpClient();

    try {
      final response = await client
          .get(
        ApiConfig.uri(ApiConfig.appStatus),
        headers: ApiConfig.defaultHeaders,
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AppStatusModel.fromJson(json, installedVersion);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  /// Vérifie l'accès utilisateur (endpoint séparé, avec token).
  static Future<UserAccessModel> getUserAccess(String accessToken) async {
    final client = ApiConfig.getHttpClient();

    try {
      final response = await client
          .get(
        ApiConfig.uri(ApiConfig.userAccess),
        headers: ApiConfig.getauthHeaders(accessToken),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UserAccessModel.fromJson(json);
      } else {
        throw Exception('Erreur accès utilisateur: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }
}