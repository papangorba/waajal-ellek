import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/auth_user_model.dart';
import '../pages/authentification/login_page.dart';
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

  bool get isAuthenticated =>
      _accessToken != null && _userProfile != null;


  int? get userId => _userProfile?.userId;
  int? get adherantId => _userProfile?.adherantId;

  Future<void> _initStorage() async {
    _storageService ??= await StorageService.getInstance();
  }

  // refresh session
  Future<void> restoreSession() async {
    try {
      await _initStorage();

      _accessToken = _storageService?.getAccessToken();
      _refreshToken = _storageService?.getRefreshToken();

      final userProfileData = _storageService?.getJson('user_profile');

      if (_accessToken != null && userProfileData != null) {
        _userProfile = UserProfile.fromJson(userProfileData);

        print('Session restaurée pour: ${_userProfile?.nomComplet}');
      } else {
        print('Aucune session trouvée');
      }
    } catch (e) {
      print('Erreur restauration session: $e');
    }

    notifyListeners();
  }

  // Save session
  Future<void> _saveSession(AuthResponse authResponse) async {
    await _initStorage();

    await _storageService?.saveAccessToken(authResponse.accessToken);
    await _storageService?.saveRefreshToken(authResponse.refreshToken);

    await _storageService?.saveJson(
        'user_profile', authResponse.userProfile.toJson());

    await _storageService?.saveBool('is_authenticated', true);

    print('Session sauvegardée');
  }

  //suppression de la session
  Future<void> _clearSession() async {
    await _initStorage();

    await _storageService?.clearTokens();
    await _storageService?.remove('user_profile');
    await _storageService?.remove('is_authenticated');

    print('Session effacée');
  }

  // login

  Future<bool> signIn(String username, String password,
      {bool rememberMe = true}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Tentative de connexion: $username');

      final authResponse = await _authService.login(username, password);

      if (authResponse != null && authResponse.status == 'SUCCESS') {
        _accessToken = authResponse.accessToken;
        _refreshToken = authResponse.refreshToken;
        _userProfile = authResponse.userProfile;

        if (rememberMe) {
          await _saveSession(authResponse);
        }

        print('Connexion réussie: ${_userProfile?.nomComplet}');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            authResponse?.message ?? 'Email ou mot de passe incorrect';

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Erreur login: $e');

      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // Refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final authResponse =
      await _authService.refreshToken(_refreshToken!);

      if (authResponse != null && authResponse.status == 'SUCCESS') {
        _accessToken = authResponse.accessToken;
        _refreshToken = authResponse.refreshToken;
        _userProfile = authResponse.userProfile;

        await _saveSession(authResponse);

        print('Token rafraîchi');

        notifyListeners();
        return true;
      } else {
        await signOut();
        return false;
      }
    } catch (e) {
      print('Erreur refresh token: $e');
      await signOut();
      return false;
    }
  }

  // déconnexion forcée si on a du  401
  Future<void> forceLogout() async {
    _accessToken = null;
    _refreshToken = null;
    _userProfile = null;
    await _clearSession();
    notifyListeners();

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // SnackBar d'avertissement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Session expirée. Veuillez vous reconnecter.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Redirection vers login en vidant la pile
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
  // logout
  Future<void> signOut() async {
    try {
      if (_accessToken != null) {
        await _authService.logout(_accessToken!);
      }
    } catch (e) {
      print('Erreur API logout: $e');
    }

    _accessToken = null;
    _refreshToken = null;
    _userProfile = null;

    await _clearSession();

    notifyListeners();

    print('Déconnexion réussie');
  }

  // reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la réinitialisation';

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  //supprimer erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}