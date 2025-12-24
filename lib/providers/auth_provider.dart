import 'package:flutter/foundation.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  StorageService? _storageService;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  static const String _userKey = 'current_user';
  static const String _isAuthenticatedKey = 'is_authenticated';

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get userId => _currentUser?['id'];

  Future<void> _initStorage() async {
    _storageService ??= await StorageService.getInstance();
  }

  Future<void> restoreSession() async {
    await _initStorage();

    final isAuth = _storageService?.getBool(_isAuthenticatedKey) ?? false;
    if (isAuth) {
      final userData = _storageService?.getJson(_userKey);
      if (userData != null) {
        _currentUser = userData;
        notifyListeners();
      }
    }
  }

  Future<void> _saveSession() async {
    await _initStorage();

    if (_currentUser != null) {
      await _storageService?.saveBool(_isAuthenticatedKey, true);
      await _storageService?.saveJson(_userKey, _currentUser!);
    }
  }

  Future<void> _clearSession() async {
    await _initStorage();

    await _storageService?.remove(_userKey);
    await _storageService?.remove(_isAuthenticatedKey);
  }

  Future<bool> signIn(String email, String password, {bool rememberMe = true}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _dataService.signIn(email, password);

      if (user != null) {
        _currentUser = user;
        if (rememberMe) {
          await _saveSession();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email ou mot de passe incorrect.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, Map<String, dynamic> userData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _dataService.signUp(email, password, userData);
      await _saveSession();
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _dataService.signOut();
      _currentUser = null;
      await _clearSession();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion.';
      notifyListeners();
    }
  }

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
      _errorMessage = 'Erreur lors de la réinitialisation du mot de passe.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
