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
    required ConnectivityService connectivityService,
  }) async {
    // Vérification de la connexion
    final isConnected = await connectivityService.checkConnection();
    if (isConnected) {
      // Mode en ligne : Appeler l'API
      try {
        final cotisations = await _fetchFromAPI(accessToken);

        // Sauvegarder en local pour la prochaine fois
        await _dbHelper.saveCotisations(userId, cotisations);
        await _dbHelper.updateSyncMetadata('cotisations_sync', DateTime.now());

        print('Cotisations chargées depuis API');
        return cotisations;
      } catch (e) {
        // Si l'API échoue, charger depuis local
        return await _dbHelper.getCotisations(userId);
      }
    } else {
      // Mode hors ligne : Charger depuis SQLite
      print('Mode hors ligne - Chargement locale');
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
      print('Requête API: $url');

      final response = await client.get(
        url,
        headers: ApiConfig.getauthHeaders(accessToken),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Cotisation.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Session expiree");
      } else {
        throw Exception("Erreur serveur ${response.statusCode}");
      }
    } finally {
      client.close();
    }
  }
}