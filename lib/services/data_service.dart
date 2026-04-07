import 'dart:convert';
import '../models/dashboard_model.dart';
import '../models/auth_user_model.dart';
import '../models/cotisation_model.dart';
import '../models/pension_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  String? _currentUserId;
  final Map<String, dynamic> _users = {
    'SEN001234': {
      'id': 'user-001',
      'email': 'amadou@gmail.com',
      'password': 'passer123',
      'matricule': 'MAT-123456',
      'nom': 'Diop',
      'prenom': 'Amadou',
      'grade': 'Sergent',
      'date_naissance': '1985-05-15',
      'date_incorporation': '2010-01-15',
      'statut': 'Actif',
      'adherant_id': 1001,
    },
    'SEN0012345': {
      'id': 'user-002',
      'email': 'fatou@gmail.com',
      'password': 'passer123',
      'matricule': 'MAT-789012',
      'nom': 'Fall',
      'prenom': 'Fatou',
      'grade': 'Capitaine',
      'date_naissance': '1982-08-20',
      'date_incorporation': '2008-03-10',
      'statut': 'Actif',
      'adherant_id': 1002,
    },
  };

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_users.containsKey(email) && _users[email]!['password'] == password) {
      _currentUserId = _users[email]!['id'];
      return _users[email];
    }
    return null;
  }

  Future<Map<String, dynamic>> signUp(String email, String password, Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    _currentUserId = userId;

    final newUser = {
      'id': userId,
      'email': email,
      'password': password,
      'adherant_id': DateTime.now().millisecondsSinceEpoch % 10000,
      ...userData,
    };

    _users[email] = newUser;
    return newUser;
  }

  void signOut() {
    _currentUserId = null;
  }

  String? get currentUserId => _currentUserId;

  //  Nouvelle méthode pour obtenir l'adherantId numérique
  int? getAdherantId(String userId) {
    final user = _users.values.firstWhere(
          (u) => u['id'] == userId,
      orElse: () => {},
    );
    return user.isNotEmpty ? user['adherant_id'] as int? : null;
  }

  UserProfile? getUserProfile(String userId) {
    final user = _users.values.firstWhere(
          (u) => u['id'] == userId,
      orElse: () => {},
    );

    if (user.isEmpty) return null;

    return UserProfile(
      userId: user['id'],
      adherantId: user['adherant_id'],
      matricule: user['matricule'],
      nom: user['nom'],
      prenom: user['prenom'],
      email: user['email'],
      grade: user['grade'],
      dateNaissance: user['date_naissance'],
      dateEngagement: user['date_incorporation'],
      statut: user['statut'],
    );
  }

  List<Cotisation> getCotisations(String userId) {
    // Utiliser l'adherantId numérique
    final adherantId = getAdherantId(userId) ?? 1001;

    return [
      Cotisation(
        id: 1,
        adherantId: adherantId,
        dateVersement: DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        montant: 125000,
        statut: 'PAYE',
        typeCotisation: 'Mensuelle',
      ),
      Cotisation(
        id: 2,
        adherantId: adherantId,
        dateVersement: DateTime.now()
            .subtract(const Duration(days: 35))
            .toIso8601String(),
        montant: 125000,
        statut: 'PAYE',
        typeCotisation: 'Mensuelle',
      ),
      Cotisation(
        id: 3,
        adherantId: adherantId,
        dateVersement: DateTime.now()
            .subtract(const Duration(days: 65))
            .toIso8601String(),
        montant: 250000,
        statut: 'PAYE',
        typeCotisation: 'Spéciale',
      ),
      Cotisation(
        id: 4,
        adherantId: adherantId,
        dateVersement: DateTime.now()
            .add(const Duration(days: 20))
            .toIso8601String(),
        montant: 125000,
        statut: 'EN_ATTENTE',
        typeCotisation: 'Mensuelle',
      ),
    ];
  }

  List<PensionModel> getPensions(String userId) {
    final adherantId = getAdherantId(userId) ?? 1001;

    return [
      PensionModel(
        id: 1,
        adherantId: adherantId,
        dateVersement: '2025-08-01',
        montant: 1200.0,
        statut: 'PAYE',
        typePension: 'Mensuelle',
      ),
      PensionModel(
        id: 2,
        adherantId: adherantId,
        dateVersement: '2025-09-01',
        montant: 1200.0,
        statut: 'PAYE',
        typePension: 'Mensuelle',
      ),
      PensionModel(
        id: 3,
        adherantId: adherantId,
        dateVersement: '2025-10-01',
        montant: 1200.0,
        statut: 'PAYE',
        typePension: 'Mensuelle',
      ),
      PensionModel(
        id: 4,
        adherantId: adherantId,
        dateVersement: '2025-11-01',
        montant: 1200.0,
        statut: 'PAYE',
        typePension: 'Mensuelle',
      ),
      PensionModel(
        id: 5,
        adherantId: adherantId,
        dateVersement: '2025-12-01',
        montant: 1200.0,
        statut: 'PAYE',
        typePension: 'Mensuelle',
      ),
      PensionModel(
        id: 6,
        adherantId: adherantId,
        dateVersement: '2026-01-01',
        montant: 1200.0,
        statut: 'PAYE',
        typePension: 'Mensuelle',
      ),
    ];
  }

  DashboardStatsModel getDashboardStats(String userId) {
    return DashboardStatsModel.fromJson({
      "panels": [
        {
          "key": "PANEL_1",
          "label": "Capital Actuel",
          "value": "1 445 000",
          "indicators": [
            {"key": "COTISATION_MENSUELLE", "label": "Cotisation Mensuelle", "value": "85 000"},
            {"key": "TOTAL_COTISATION_ACTUELLE", "label": "Cotisations cumulées", "value": "1 445 000"},
          ]
        },
        {
          "key": "PANEL_2",
          "label": "Capital Retraite Est.",
          "value": "80 412 620",
          "indicators": [
            {"key": "TOTAL_RENDEMENT_RETRAITE", "label": "Total Rendement Est.", "value": "38 232 620"},
            {"key": "TOTAL_COTISATION_RETRAITE", "label": "Total Cotisation Est.", "value": "42 180 000"},
          ]
        },
        {
          "key": "PANEL_3",
          "label": "Date de retraite",
          "value": "29 déc. 2062",
          "indicators": [
            {"key": "DATE_ADHESION", "label": "Date d'adhésion", "value": "06 janv. 2026"},
            {"key": "PERIODE_RESTANTE", "label": "Période Restante", "value": "36 ans, 8 mois"},
          ]
        },
        {
          "key": "PANEL_4",
          "label": "Pension Estimée",
          "value": "790 840",
          "indicators": [
            {"key": "PENSION_RECUE", "label": "Type de projection", "value": "Rente sur 10 ans"},
            {"key": "TAUX_REMPLACEMENT", "label": "Taux de Remplacement", "value": "72 %"},
          ]
        },
      ]
    });
  }

  List<Map<String, dynamic>> getRecentActivities(String userId) {
    final adherantId = getAdherantId(userId) ?? 1001;


    return [
      {
        'id': 1,
        'adherantId': adherantId,
        'dateVersement': '2025-12-01',
        'montant': 250.0,
        'statut': 'PAYE',
        'type': 'COTISATION',
        'typeTransaction': 'Mensuelle',
      },
      {
        'id': 2,
        'adherantId': adherantId,
        'dateVersement': '2025-11-01',
        'montant': 1200.0,
        'statut': 'PAYE',
        'type': 'PENSION',
        'typeTransaction': 'Mensuelle',
      },
      {
        'id': 3,
        'adherantId': adherantId,
        'dateVersement': '2025-10-01',
        'montant': 250.0,
        'statut': 'PAYE',
        'type': 'COTISATION',
        'typeTransaction': 'Spéciale',
      },
      {
        'id': 4,
        'adherantId': adherantId,
        'dateVersement': '2025-09-01',
        'montant': 250.0,
        'statut': 'EN_COURS',
        'type': 'RACHAT',
        'typeTransaction': 'Spéciale',
      },
    ];
  }
}