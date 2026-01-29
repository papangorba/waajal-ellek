class Cotisation {
  final int id;
  final int adherantId;
  final String dateVersement;
  final double montant;
  final String statut;
  final String typeCotisation;

  Cotisation({
    required this.id,
    required this.adherantId,
    required this.dateVersement,
    required this.montant,
    required this.statut,
    required this.typeCotisation,
  });

  factory Cotisation.fromJson(Map<String, dynamic> json) {
    return Cotisation(
      id: json['id'],
      adherantId: json['adherantId'],
      dateVersement: json['dateVersement'],
      montant: (json['montant'] as num).toDouble(),
      statut: json['statut'],
      typeCotisation: json['typeCotisation'],
    );
  }
}
