import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/data_service.dart';

class UserProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 300));

      _userProfile = _dataService.getUserProfile(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du profil.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 300));

      if (_userProfile != null) {
        _userProfile = UserModel(
          id: _userProfile!.id,
          matricule: updates['matricule'] ?? _userProfile!.matricule,
          nom: updates['nom'] ?? _userProfile!.nom,
          prenom: updates['prenom'] ?? _userProfile!.prenom,
          email: updates['email'] ?? _userProfile!.email,
          telephone: updates['telephone'] ?? _userProfile!.telephone,
          grade: updates['grade'] ?? _userProfile!.grade,
          dateNaissance: updates['date_naissance'] != null
              ? DateTime.parse(updates['date_naissance'])
              : _userProfile!.dateNaissance,
          dateEngagement: updates['date_engagement'] != null
              ? DateTime.parse(updates['date_engagement'])
              : _userProfile!.dateEngagement,
          dateRetraite: updates['date_retraite'] != null
              ? DateTime.parse(updates['date_retraite'])
              : _userProfile!.dateRetraite,
          statut: updates['statut'] ?? _userProfile!.statut,
        );
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du profil.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }
}
