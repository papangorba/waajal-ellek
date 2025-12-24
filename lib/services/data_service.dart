import 'dart:convert';
import '../models/user_model.dart';
import '../models/cotisation_model.dart';
import '../models/pension_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  String? _currentUserId;
  final Map<String, dynamic> _users = {
    'amadou@gmail.com': {
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
    },
    'fatou@gmail.com': {
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
      ...userData,
    };

    _users[email] = newUser;
    return newUser;
  }

  void signOut() {
    _currentUserId = null;
  }

  String? get currentUserId => _currentUserId;

  UserModel? getUserProfile(String userId) {
    final user = _users.values.firstWhere(
          (u) => u['id'] == userId,
      orElse: () => {},
    );

    if (user.isEmpty) return null;

    return UserModel(
      id: user['id'],
      matricule: user['matricule'],
      nom: user['nom'],
      prenom: user['prenom'],
      email: user['email'],
      grade: user['grade'],
      dateNaissance: DateTime.parse(user['date_naissance']),
      dateEngagement: DateTime.parse(user['date_incorporation']),
      statut: user['statut'],
    );
  }

  List<CotisationModel> getCotisations(String userId) {
    return [
      CotisationModel(
        id: 'cot-001',
        userId: userId,
        dateCotisation: DateTime.now().subtract(const Duration(days: 5)),
        montant: 125000.0,
        pointsAcquis: 50,
        typeCotisation: 'Mensuelle',
        statut: 'paye',
      ),
      CotisationModel(
        id: 'cot-002',
        userId: userId,
        dateCotisation: DateTime.now().subtract(const Duration(days: 35)),
        montant: 125000.0,
        pointsAcquis: 50,
        typeCotisation: 'Mensuelle',
        statut: 'paye',
      ),
      CotisationModel(
        id: 'cot-003',
        userId: userId,
        dateCotisation: DateTime.now().subtract(const Duration(days: 65)),
        montant: 125000.0,
        pointsAcquis: 50,
        typeCotisation: 'Mensuelle',
        statut: 'paye',
      ),
      CotisationModel(
        id: 'cot-004',
        userId: userId,
        dateCotisation: DateTime.now().subtract(const Duration(days: 95)),
        montant: 250000.0,
        pointsAcquis: 100,
        typeCotisation: 'Spéciale',
        statut: 'paye',
      ),
      CotisationModel(
        id: 'cot-005',
        userId: userId,
        dateCotisation: DateTime.now().subtract(const Duration(days: 125)),
        montant: 125000.0,
        pointsAcquis: 50,
        typeCotisation: 'Mensuelle',
        statut: 'paye',
      ),
      CotisationModel(
        id: 'cot-006',
        userId: userId,
        dateCotisation: DateTime.now().add(const Duration(days: 25)),
        montant: 125000.0,
        pointsAcquis: 50,
        typeCotisation: 'Mensuelle',
        statut: 'en_attente',
      ),
    ];
  }

  List<PensionModel> getPensions(String userId) {
    return [
      PensionModel(
        id: 'pen-001',
        userId: userId,
        typePension: 'Pension de retraite',
        montantMensuel: 350000.0,
        dateDebut: DateTime(2023, 1, 1),
        statut: 'actif',
        totalPoints: 1250,
        valeurPoint: 280.0,
      ),
    ];
  }

  Map<String, dynamic> getDashboardStats(String userId) {
    final cotisations = getCotisations(userId);
    final pensions = getPensions(userId);

    double totalCotisations = 0;
    int totalPoints = 0;
    int nombreCotisations = 0;

    for (var cot in cotisations) {
      if (cot.isPaid) {
        totalCotisations += cot.montant;
        totalPoints += cot.pointsAcquis;
        nombreCotisations++;
      }
    }

    double montantPension = pensions.isNotEmpty ? pensions[0].montantMensuel : 0.0;

    return {
      'totalCotisations': totalCotisations,
      'totalPoints': totalPoints,
      'montantPension': montantPension,
      'nombreCotisations': nombreCotisations,
    };
  }

  List<Map<String, dynamic>> getRecentActivities(String userId) {
    final cotisations = getCotisations(userId);
    final recent = cotisations.where((c) => c.isPaid).take(5).toList();

    return recent.map((c) => {
      'date_cotisation': c.dateCotisation.toIso8601String(),
      'montant': c.montant,
      'type_cotisation': c.typeCotisation,
    }).toList();
  }
}
