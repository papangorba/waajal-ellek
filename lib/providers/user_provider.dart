import 'package:flutter/foundation.dart';
import '../models/auth_user_model.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
    notifyListeners();
  }


  Future<void> fetchUserProfile(String userId) async {

    // Si on a un endpoint /api/user/profile/{userId}
    /*
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        ApiConfig.uri('/api/user/profile/$userId'),
        headers: ApiConfig.getauthHeaders(accessToken),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userProfile = UserProfile.fromJson(data);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du profil.';
      _isLoading = false;
      notifyListeners();
    }
    */
  }

  // Mise à jour du profil
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      // l'appel api pour mettre à jour le profil
      // final response = await http.put(
      //   ApiConfig.uri('/api/user/profile'),
      //   headers: ApiConfig.getauthHeaders(accessToken),
      //   body: jsonEncode(updates),
      // );

      await Future.delayed(const Duration(milliseconds: 300));

      // Pour l'instant, mise à jour locale uniquement
      if (_userProfile != null) {
        _userProfile = UserProfile(
          userId: _userProfile!.userId,
          adherantId: _userProfile!.adherantId,
          matricule: updates['matricule'] ?? _userProfile!.matricule,
          nom: updates['nom'] ?? _userProfile!.nom,
          prenom: updates['prenom'] ?? _userProfile!.prenom,
          email: updates['email'] ?? _userProfile!.email,
          telephone: updates['telephone'] ?? _userProfile!.telephone,
          grade: updates['grade'] ?? _userProfile!.grade,
          dateNaissance: updates['dateNaissance'] ?? _userProfile!.dateNaissance,
          dateEngagement: updates['dateEngagement'] ?? _userProfile!.dateEngagement,
          dateRetraite: updates['dateRetraite'] ?? _userProfile!.dateRetraite,
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

  //Effacer le profil
  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }
}