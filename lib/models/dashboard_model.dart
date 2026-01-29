//  Modèle pour le dashboard
class DashboardStatsModel {
  final double capitalRetraite;
  final double cotisationMensuelle;
  final double totalCotisations;
  final double pensionEstimee;
  final double tauxRemplacement;
  final double projection5ans;
  final int anneesService;
  final int ageActuel;
  final int anneesAvantRetraite;
  final double interetsCumules;
  final double tauxInteret;
  final double projection10ans;

  DashboardStatsModel({
    required this.capitalRetraite,
    required this.cotisationMensuelle,
    required this.totalCotisations,
    required this.pensionEstimee,
    required this.tauxRemplacement,
    required this.projection5ans,
    required this.anneesService,
    required this.ageActuel,
    required this.anneesAvantRetraite,
    required this.interetsCumules,
    required this.tauxInteret,
    required this.projection10ans,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final panels = json['panels'] as List<dynamic>;

    double getValue(String key) {
      final panel = panels.firstWhere(
            (p) => p['key'] == key,
        orElse: () => {'value': '0'},
      );
      return double.tryParse(panel['value'].toString()) ?? 0.0;
    }

    double getIndicator(String panelKey, String indicatorKey) {
      final panel = panels.firstWhere(
            (p) => p['key'] == panelKey,
        orElse: () => {'indicators': []},
      );

      final indicators = panel['indicators'] as List<dynamic>? ?? [];
      final indicator = indicators.firstWhere(
            (i) => i['key'] == indicatorKey,
        orElse: () => {'value': '0'},
      );

      return double.tryParse(indicator['value'].toString()) ?? 0.0;
    }

    int getIndicatorInt(String panelKey, String indicatorKey) {
      return getIndicator(panelKey, indicatorKey).toInt();
    }

    return DashboardStatsModel(
      capitalRetraite: getValue('CAPITAL_RETRAITE'),
      cotisationMensuelle: getIndicator('CAPITAL_RETRAITE', 'COTISATION_MENSUEL'),
      totalCotisations: getIndicator('CAPITAL_RETRAITE', 'TOTAL_COTISE'),
      pensionEstimee: getValue('PENSION_ESTIMEE'),
      tauxRemplacement: getIndicator('PENSION_ESTIMEE', 'TAUX_REMPLACEMENT') / 100,
      projection5ans: getIndicator('PENSION_ESTIMEE', 'PROJECTION_5ANS'),
      anneesService: getValue('ANNEES_SERVICE').toInt(),
      ageActuel: getIndicatorInt('ANNEES_SERVICE', 'AGE_ACTUEL'),
      anneesAvantRetraite: getIndicatorInt('ANNEES_SERVICE', 'AVANT_RETRAITE'),
      interetsCumules: getValue('INTERETS_CUMULES'),
      tauxInteret: getIndicator('INTERETS_CUMULES', 'TAUX_INTERET') / 100,
      projection10ans: getIndicator('INTERETS_CUMULES', 'PROJECTION_10ANS'),
    );
  }
}

//  Modèle pour les activités récentes
class RecentActivityModel {
  final int id;
  final int adherantId;
  final String dateVersement;
  final double montant;
  final String statut;
  final String type;
  final String typeTransaction;

  RecentActivityModel({
    required this.id,
    required this.adherantId,
    required this.dateVersement,
    required this.montant,
    required this.statut,
    required this.type,
    required this.typeTransaction,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'] as int,
      adherantId: json['adherantId'] as int,
      dateVersement: json['dateVersement'] as String,
      montant: (json['montant'] as num).toDouble(),
      statut: json['statut'] as String,
      type: json['type'] as String,
      typeTransaction: json['typeTransaction'] as String,
    );
  }


  DateTime get date {
    try {
      return DateTime.parse(dateVersement);
    } catch (e) {
      return DateTime.now();
    }
  }


  bool get isPaid => statut.toUpperCase() == 'PAYE';
}