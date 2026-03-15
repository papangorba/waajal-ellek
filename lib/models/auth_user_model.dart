class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String message;
  final String status;
  final UserProfile userProfile;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
    required this.status,
    required this.userProfile,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      userProfile: UserProfile.fromJson(json['userProfile'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'message': message,
      'status': status,
      'userProfile': userProfile.toJson(),
    };
  }
}

class UserProfile {
  final int? adherantId;
  final int? userId;
  final String matricule;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String grade;
  final String statut;
  final String? dateNaissance;
  final String? dateEngagement;
  final String? dateRetraite;
  final String? createdAt;
  final String? updatedAt;

  UserProfile({
    this.adherantId,
    this.userId,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.grade,
    required this.statut,
    this.dateNaissance,
    this.dateEngagement,
    this.dateRetraite,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      adherantId: json['adherantId'],
      userId: json['userId'],
      matricule: json['matricule'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String?,
      grade: json['grade'] as String,
      statut: json['statut'] as String,
      dateNaissance: json['dateNaissance'] as String?,
      dateEngagement: json['dateEngagement'] as String?,
      dateRetraite: json['dateRetraite'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adherantId': adherantId,
      'userId': userId,
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'grade': grade,
      'statut': statut,
      'dateNaissance': dateNaissance,
      'dateEngagement': dateEngagement,
      'dateRetraite': dateRetraite,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  String get nomComplet => '$prenom $nom';

  bool get isRetraite => statut.toUpperCase() == 'RETRAITE';
}