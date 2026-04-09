import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  // Clés pour le stockage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userProfileKey = 'user_profile';
  static const String _isAuthenticatedKey = 'is_authenticated';

  StorageService._();

  // StorageService — rendre l'init atomique
  static Future<StorageService> getInstance() async {
    if (_instance != null && _preferences != null) return _instance!;

    _preferences = await SharedPreferences.getInstance(); // toujours await
    _instance = StorageService._();
    return _instance!;
  }

  //Gestion des tokens
  //Sauvegarder l'access token
  Future<void> saveAccessToken(String token) async {
    await _preferences?.setString(_accessTokenKey, token);
  }

  //Récupérer l'access token
  String? getAccessToken() {
    return _preferences?.getString(_accessTokenKey);
  }

  //Sauvegarder le refresh token
  Future<void> saveRefreshToken(String token) async {
    await _preferences?.setString(_refreshTokenKey, token);
  }

  //Récupérer le refresh token
  String? getRefreshToken() {
    return _preferences?.getString(_refreshTokenKey);
  }

  //Supprimer les tokens
  Future<void> clearTokens() async {
    await _preferences?.remove(_accessTokenKey);
    await _preferences?.remove(_refreshTokenKey);
  }

  //Vérifier si un access token existe
  bool hasAccessToken() {
    final token = _preferences?.getString(_accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  //Methode generale
  Future<void> saveString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  Future<void> saveDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _preferences?.setString(key, jsonString);
  }

  Map<String, dynamic>? getJson(String key) {
    final jsonString = _preferences?.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  Future<void> clear() async {
    await _preferences?.clear();
  }

  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  Set<String> getKeys() {
    return _preferences?.getKeys() ?? {};
  }
}