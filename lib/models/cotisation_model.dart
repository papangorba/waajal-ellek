class CotisationModel {
  final String id;
  final String userId;
  final DateTime dateCotisation;
  final double montant;
  final int pointsAcquis;
  final String statut;
  final String? reference;
  final String typeCotisation;

  CotisationModel({
    required this.id,
    required this.userId,
    required this.dateCotisation,
    required this.montant,
    required this.pointsAcquis,
    required this.statut,
    this.reference,
    required this.typeCotisation,
  });

  factory CotisationModel.fromJson(Map<String, dynamic> json) {
    return CotisationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      dateCotisation: DateTime.parse(json['date_cotisation'] as String),
      montant: (json['montant'] as num).toDouble(),
      pointsAcquis: json['points_acquis'] as int,
      statut: json['statut'] as String,
      reference: json['reference'] as String?,
      typeCotisation: json['type_cotisation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_cotisation': dateCotisation.toIso8601String(),
      'montant': montant,
      'points_acquis': pointsAcquis,
      'statut': statut,
      'reference': reference,
      'type_cotisation': typeCotisation,
    };
  }

  bool get isPaid => statut == 'paye';
}
