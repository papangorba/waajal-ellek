import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../models/auth_user_model.dart';


class _AuthHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Future<bool> Function() onRefreshToken;
  final Future<void> Function() onForceLogout;

  _AuthHttpClient({
    required this.onRefreshToken,
    required this.onForceLogout,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      final refreshed = await onRefreshToken();
      if (!refreshed) {
        await onForceLogout();
      }
    }

    return response;
  }
}

class AuthService {
  final http.Client _client = ApiConfig.getHttpClient();

  //endpoint de login
  static const String _loginEndpoint = '/api/mobile/auth/login';
  static const String _refreshEndpoint = '/api/auth/refresh';

  Future<AuthResponse?> login(String username, String password) async {
    try {
      final uri = ApiConfig.uri(_loginEndpoint);

      final response = await _client.post(
        uri,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );


      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'SUCCESS') {
          return AuthResponse.fromJson(jsonResponse);
        } else {
          print(' echec de connexion: ${jsonResponse['message']}');
          return null;
        }
      } else {
        print(' erreur HTTP: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print(' Exception lors de la connexion: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<AuthResponse?> refreshToken(String refreshToken) async {
    try {
      final uri = ApiConfig.uri(_refreshEndpoint);

      final response = await _client.post(
        uri,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'SUCCESS') {
          return AuthResponse.fromJson(jsonResponse);
        }
      }

      return null;
    } catch (e) {
      print('erreur lors du refresh token: $e');
      return null;
    }
  }

  Future<bool> logout(String accessToken) async {
    try {
      // Si on a un endpoint de logout
      // final uri = ApiConfig.uri('/api/auth/logout');
      // final response = await _client.post(
      //   uri,
      //   headers: ApiConfig.getauthHeaders(accessToken),
      // );
      // return response.statusCode == 200;

      // Pour l'instant, (déconnexion locale uniquement)
      return true;
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      return false;
    }
  }
}