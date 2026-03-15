import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../models/cotisation_model.dart';
import 'database_helper.dart';
import 'connectivity_service.dart';

class CotisationService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<List<Cotisation>> getCotisations({
    required String accessToken,
    required String userId,
    required int adherantId,
    required ConnectivityService connectivityService,
  }) async {
    final isConnected = await connectivityService.checkConnection();

    if (isConnected) {
      try {
        final cotisations = await _fetchFromAPI(accessToken);

        try {
          await _dbHelper.saveCotisations(userId, adherantId, cotisations);
          await _dbHelper.updateSyncMetadata('cotisations_sync', DateTime.now());
        } catch (dbError) {
          print(' Erreur sauvegarde cotisations: $dbError');
        }

        return cotisations;

      } catch (e) {
        return await _dbHelper.getCotisations(userId);
      }
    } else {
      print('Mode hors ligne - Chargement cotisations localement');
      final localData = await _dbHelper.getCotisations(userId);

      if (localData.isEmpty) {
        throw Exception("Aucune donnée locale. Veuillez vous connecter à Internet.");
      }

      return localData;
    }
  }

  static Future<List<Cotisation>> _fetchFromAPI(String accessToken) async {
    final client = ApiConfig.getHttpClient();

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cotisations}');
      print('Requête API cotisations: $url');

      final response = await client.get(
        url,
        headers: ApiConfig.getauthHeaders(accessToken),
      ).timeout(const Duration(seconds: 30));

      print('Status code: ${response.statusCode}');

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
          print('Structure inattendue: $decoded');
          rawList = [];
        }

        return rawList.map((e) => Cotisation.fromJson(e)).toList();

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