import 'package:flutter/foundation.dart';
import '../models/auth_user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  StorageService? _storageService;

  String? _accessToken;
  String? _refreshToken;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _accessToken != null && _userProfile != null;
  String? get userId => _userProfile?.id;

  Future<void> _initStorage() async {
    _storageService ??= await StorageService.getInstance();
  }

  //Restaurer la session  localement
  Future<void> restoreSession() async {
    await _initStorage();

    _accessToken = _storageService?.getAccessToken();
    _refreshToken = _storageService?.getRefreshToken();

    if (_accessToken != null) {
      final userProfileData = _storageService?.getJson('user_profile');
      if (userProfileData != null) {
        _userProfile = UserProfile.fromJson(userProfileData);
        notifyListeners();

        print('Session restauree pour: ${_userProfile?.nomComplet}');
      }
    }
  }

  //Sauvegarder la session
  Future<void> _saveSession(AuthResponse authResponse) async {
    await _initStorage();

    // Sauvegarde du token
    await _storageService?.saveAccessToken(authResponse.accessToken);
    await _storageService?.saveRefreshToken(authResponse.refreshToken);
    // Sauvegarder le profil utilisateur
    await _storageService?.saveJson('user_profile', authResponse.userProfile.toJson());
    await _storageService?.saveBool('is_authenticated', true);
    print('Session sauvegardée');
  }

  //Effacer la session
  Future<void> _clearSession() async {
    await _initStorage();
    await _storageService?.clearTokens();
    await _storageService?.remove('user_profile');
    await _storageService?.remove('is_authenticated');
    print('Session effacée');
  }
  //Connexion
  Future<bool> signIn(String username, String password, {bool rememberMe = true}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Tentative de connexion pour: $username');

      final authResponse = await _authService.login(username, password);
      if (authResponse != null && authResponse.status == 'SUCCESS') {
        _accessToken = authResponse.accessToken;
        _refreshToken = authResponse.refreshToken;
        _userProfile = authResponse.userProfile;

        if (rememberMe) {
          await _saveSession(authResponse);
        }

        _isLoading = false;
        notifyListeners();

        print('Connexion reussie: ${_userProfile?.nomComplet}');
        return true;
      } else {
        _errorMessage = authResponse?.message ?? 'Email ou mot de passe incorrect.';
        _isLoading = false;
        notifyListeners();

        print('Echec de connexion: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  //Rafraîchir le token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) {
      return false;
    }

    try {
      final authResponse = await _authService.refreshToken(_refreshToken!);

      if (authResponse != null && authResponse.status == 'SUCCESS') {
        _accessToken = authResponse.accessToken;
        _refreshToken = authResponse.refreshToken;
        _userProfile = authResponse.userProfile;

        await _saveSession(authResponse);
        notifyListeners();

        print('Token rafraîchi avec succes');
        return true;
      } else {
        await signOut();
        return false;
      }
    } catch (e) {
      await signOut();
      return false;
    }
  }

  //Deconnexion
  Future<void> signOut() async {
    try {
      if (_accessToken != null) {
        await _authService.logout(_accessToken!);
      }

      _accessToken = null;
      _refreshToken = null;
      _userProfile = null;

      await _clearSession();
      notifyListeners();

      print('Deconnexion réussie');
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion.';
      notifyListeners();

      print('Erreur lors de la déconnexion: $e');
    }
  }

  //Réinitialiser le mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // TODO: Implémenter avec votre endpoint backend
      await Future.delayed(const Duration(milliseconds: 500));

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la réinitialisation du mot de passe.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //Effacer les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}