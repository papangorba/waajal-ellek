import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/apiconfig.dart';
import '../models/app_status_model.dart';

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
}