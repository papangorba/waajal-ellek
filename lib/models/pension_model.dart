class PensionModel {
  final String id;
  final String userId;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final double montantMensuel;
  final String typePension;
  final String statut;
  final int totalPoints;
  final double valeurPoint;

  PensionModel({
    required this.id,
    required this.userId,
    required this.dateDebut,
    this.dateFin,
    required this.montantMensuel,
    required this.typePension,
    required this.statut,
    required this.totalPoints,
    required this.valeurPoint,
  });

  factory PensionModel.fromJson(Map<String, dynamic> json) {
    return PensionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      dateDebut: DateTime.parse(json['date_debut'] as String),
      dateFin: json['date_fin'] != null
          ? DateTime.parse(json['date_fin'] as String)
          : null,
      montantMensuel: (json['montant_mensuel'] as num).toDouble(),
      typePension: json['type_pension'] as String,
      statut: json['statut'] as String,
      totalPoints: json['total_points'] as int,
      valeurPoint: (json['valeur_point'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'montant_mensuel': montantMensuel,
      'type_pension': typePension,
      'statut': statut,
      'total_points': totalPoints,
      'valeur_point': valeurPoint,
    };
  }

  bool get isActive => statut == 'actif';
}
