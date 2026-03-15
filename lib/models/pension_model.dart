class PensionModel {
  final int id;
  final int adherantId;
  final String? dateVersement;
  final double montant;
  final String? statut;
  final String typePension;

  PensionModel({
    required this.id,
    required this.adherantId,
    this.dateVersement,
    required this.montant,
    this.statut,
    required this.typePension,
  });

  factory PensionModel.fromJson(Map<String, dynamic> json) {
    return PensionModel(
      id: json['id'] as int,
      adherantId: json['adherantId'] as int,
      dateVersement: json['dateVersement'] as String?,
      montant: (json['montant'] as num).toDouble(),
      statut: json['statut'] as String?,
      typePension: json['typePension'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adherantId': adherantId,
      'dateVersement': dateVersement,
      'montant': montant,
      'statut': statut,
      'typePension': typePension,
    };
  }

  bool get isPaid {
    if (statut == null) return false;
    final s = statut!.toLowerCase().replaceAll('é', 'e').trim();
    return s == 'paye' || s == 'actif';
  }

  DateTime get date {
    if (dateVersement == null || dateVersement!.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(dateVersement!);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'PensionModel(id: $id, montant: $montant, date: $dateVersement, statut: $statut)';
  }
}