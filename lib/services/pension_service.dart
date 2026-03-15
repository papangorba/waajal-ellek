import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../models/pension_model.dart';
import 'database_helper.dart';
import 'connectivity_service.dart';

class PensionService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<List<PensionModel>> getPensions({
    required String accessToken,
    required String userId,
    required int adherantId,
    required ConnectivityService connectivityService,
  }) async {
    final isConnected = await connectivityService.checkConnection();

    if (isConnected) {
      try {
        final pensions = await _fetchFromAPI(accessToken);

        try {
          await _dbHelper.savePensions(userId, adherantId, pensions);
          await _dbHelper.updateSyncMetadata('pensions_sync', DateTime.now());
        } catch (dbError) {
          print('Erreur sauvegarde pensions: $dbError');
        }
        return pensions;

      } catch (e) {
        return await _dbHelper.getPensions(userId);
      }
    } else {
      print('Mode hors ligne - Chargement pensions localement');
      final localData = await _dbHelper.getPensions(userId);

      if (localData.isEmpty) {
        throw Exception("Aucune donnée locale. Veuillez vous connecter à Internet.");
      }

      return localData;
    }
  }

  static Future<List<PensionModel>> _fetchFromAPI(String accessToken) async {
    final client = ApiConfig.getHttpClient();

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.pensions}');
      print('Requête API pensions: $url');

      final response = await client.get(
        url,
        headers: ApiConfig.getauthHeaders(accessToken),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        List rawList;
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          rawList = decoded['data'] as List;
        } else if (decoded is Map && decoded.containsKey('content')) {
          rawList = decoded['content'] as List;
        } else {
          rawList = [];
        }

        print('Nombre pensions parsées: ${rawList.length}');
        return rawList.map((e) => PensionModel.fromJson(e)).toList();

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