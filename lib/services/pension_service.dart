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
    required ConnectivityService connectivityService,
  }) async {
    // Vérifier la connexion
    final isConnected = await connectivityService.checkConnection();

    if (isConnected) {
      // Mode en ligne : Appel l'API
      try {
        final pensions = await _fetchFromAPI(accessToken);

        // Sauvegarder en local
        await _dbHelper.savePensions(userId, pensions);
        await _dbHelper.updateSyncMetadata('pensions_sync', DateTime.now());

        print('Pensions chargées depuis API');
        return pensions;
      } catch (e) {
        return await _dbHelper.getPensions(userId);
      }
    } else {
      // Mode hors ligne : Charger depuis SQLite
      print('Mode hors ligne - Chargement depuis cache');
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
      print('Requête API: $url');

      final response = await client.get(
        url,
        headers: ApiConfig.getauthHeaders(accessToken),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => PensionModel.fromJson(e)).toList();
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