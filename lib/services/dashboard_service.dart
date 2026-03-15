import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../models/dashboard_model.dart';
import 'database_helper.dart';
import 'connectivity_service.dart';

class DashboardService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // DASHBOARD STATS

  static Future<DashboardStatsModel> getDashboardStats({
    required String accessToken,
    required String userId,
    required ConnectivityService connectivityService,
  }) async {
    final isConnected = await connectivityService.checkConnection();

    if (isConnected) {
      try {
        final stats = await _fetchStatsFromAPI(accessToken);

        try {
          await _dbHelper.saveDashboardStats(userId, stats);

          await _dbHelper.updateSyncMetadata('dashboard_sync', DateTime.now().toUtc());
        } catch (dbError) {
          print('Erreur sauvegarde stats: $dbError');
        }

        //Retourner directement depuis l'API
        return stats;
      } catch (e) {
        final localStats = await _dbHelper.getDashboardStats(userId);
        if (localStats != null) return localStats;
        rethrow;
      }
    } else {
      print('Mode hors ligne - Chargement dashboard localement');
      final localStats = await _dbHelper.getDashboardStats(userId);
      if (localStats == null) {
        throw Exception("Aucune donnée locale. Veuillez vous connecter à Internet.");
      }
      return localStats;
    }
  }

  static Future<DateTime?> getLastDashboardSync() async {
    return await _dbHelper.getLastSync('dashboard_sync');
  }

  // ACTIVITÉS RÉCENTES
  static Future<List<RecentActivityModel>> getRecentActivities({
    required String accessToken,
    required String userId,
    required ConnectivityService connectivityService,
  }) async {
    final isConnected = await connectivityService.checkConnection();

    if (isConnected) {
      try {
        final activities = await _fetchActivitiesFromAPI(accessToken);

        try {
          await _dbHelper.saveRecentActivities(userId, activities);
          await _dbHelper.updateSyncMetadata('activities_sync', DateTime.now().toUtc());
        } catch (dbError) {
          print(' Erreur sauvegarde activités: $dbError');
        }

        //Retourner directement depuis l'API
        return activities;
      } catch (e) {
        return await _dbHelper.getRecentActivities(userId);
      }
    } else {
      print('Mode hors ligne - Chargement activités localement');
      final localActivities = await _dbHelper.getRecentActivities(userId);
      if (localActivities.isEmpty) {
        throw Exception("Aucune donnée locale. Veuillez vous connecter à Internet.");
      }
      return localActivities;
    }
  }

  // Fetch api prives
  static Future<DashboardStatsModel> _fetchStatsFromAPI(String accessToken) async {
    final client = ApiConfig.getHttpClient();
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dashboard}');
      print('Requête dashboard: $url');

      final response = await client.get(
        url,
        headers: ApiConfig.getauthHeaders(accessToken),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dashboardData = decoded['data'] ?? decoded;
        return DashboardStatsModel.fromJson(dashboardData);
      } else if (response.statusCode == 401) {
        throw Exception("Session expirée");
      } else {
        throw Exception("Erreur serveur ${response.statusCode}");
      }
    } finally {
      client.close();
    }
  }

  static Future<List<RecentActivityModel>> _fetchActivitiesFromAPI(String accessToken) async {
    final client = ApiConfig.getHttpClient();
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transaction_recent}');
      print('Requête activités: $url');

      final response = await client.get(
        url,
        headers: ApiConfig.getauthHeaders(accessToken),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        //Gérer liste directe OU objet avec clé "data"
        List rawList;
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          rawList = decoded['data'] as List;
        } else {
          rawList = [];
        }

        return rawList.map((e) => RecentActivityModel.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Session expirée");
      } else {
        throw Exception("Erreur serveur ${response.statusCode}");
      }
    } finally {
      client.close();
    }
  }
}