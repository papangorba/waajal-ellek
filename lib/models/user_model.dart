class UserModel {
  final String id;
  final String matricule;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String grade;
  final String statut;
  final DateTime? dateNaissance;
  final DateTime? dateEngagement;
  final DateTime? dateRetraite;
  final String? photoUrl;

  UserModel({
    required this.id,
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
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      matricule: json['matricule'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String?,
      grade: json['grade'] as String,
      statut: json['statut'] as String,
      dateNaissance: json['date_naissance'] != null
          ? DateTime.parse(json['date_naissance'] as String)
          : null,
      dateEngagement: json['date_engagement'] != null
          ? DateTime.parse(json['date_engagement'] as String)
          : null,
      dateRetraite: json['date_retraite'] != null
          ? DateTime.parse(json['date_retraite'] as String)
          : null,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'grade': grade,
      'statut': statut,
      'date_naissance': dateNaissance?.toIso8601String(),
      'date_engagement': dateEngagement?.toIso8601String(),
      'date_retraite': dateRetraite?.toIso8601String(),
      'photo_url': photoUrl,
    };
  }

  String get nomComplet => '$prenom $nom';

  bool get isRetraite => statut == 'retraite';
}
