// Modèle pour le dashboard
class DashboardStatsModel {
  // PANEL_1 - Total Cotisation
  final double totalCotisation;
  final double cotisationMensuelle;
  final double cotisationRetraite;

  // PANEL_2 - Capital Actuel
  final double capitalActuel;
  final double tauxRendement;
  final double rendementCumule;

  // PANEL_3 - Date d'adhésion
  final String dateAdhesion;
  final String periodeCumulee;
  final String periodeRestante;

  // PANEL_4 - Date de retraite
  final String dateRetraite;
  final double pensionMensuelle;
  final String pensionRecue;

  DashboardStatsModel({
    required this.totalCotisation,
    required this.cotisationMensuelle,
    required this.cotisationRetraite,
    required this.capitalActuel,
    required this.tauxRendement,
    required this.rendementCumule,
    required this.dateAdhesion,
    required this.periodeCumulee,
    required this.periodeRestante,
    required this.dateRetraite,
    required this.pensionMensuelle,
    required this.pensionRecue,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final panels = json['panels'] as List<dynamic>;

    // Helper : value principale d'un panel
    String getPanelValue(String panelKey) {
      final panel = panels.firstWhere(
            (p) => p['key'] == panelKey,
        orElse: () => {'value': '0'},
      );
      return panel['value']?.toString() ?? '0';
    }

    double getPanelDouble(String panelKey) {
      return double.tryParse(getPanelValue(panelKey)) ?? 0.0;
    }

    // Helper : indicateur dans un panel
    String getIndicator(String panelKey, String indicatorKey) {
      final panel = panels.firstWhere(
            (p) => p['key'] == panelKey,
        orElse: () => {'indicators': []},
      );
      final indicators = panel['indicators'] as List<dynamic>? ?? [];
      final indicator = indicators.firstWhere(
            (i) => i['key'] == indicatorKey,
        orElse: () => {'value': '0'},
      );
      return indicator['value']?.toString() ?? '0';
    }

    double getIndicatorDouble(String panelKey, String indicatorKey) {
      return double.tryParse(getIndicator(panelKey, indicatorKey)) ?? 0.0;
    }

    return DashboardStatsModel(
      // PANEL_1
      totalCotisation: getPanelDouble('PANEL_1'),
      cotisationMensuelle: getIndicatorDouble('PANEL_1', 'COTISATION_MENSUEL'),
      cotisationRetraite: getIndicatorDouble('PANEL_1', 'COTISATION_RETRAITE'),

      // PANEL_2
      capitalActuel: getPanelDouble('PANEL_2'),
      tauxRendement: getIndicatorDouble('PANEL_2', 'TAUX_RENDEMENT'),
      rendementCumule: getIndicatorDouble('PANEL_2', 'RENDEMENT_CUMMULE'),

      // PANEL_3
      dateAdhesion: getPanelValue('PANEL_3'),
      periodeCumulee: getIndicator('PANEL_3', 'PERIODE_CUMULEE'),
      periodeRestante: getIndicator('PANEL_3', 'PERIODE_RESTANTE'),

      // PANEL_4
      dateRetraite: getPanelValue('PANEL_4'),
      pensionMensuelle: getIndicatorDouble('PANEL_4', 'PENSION_MENSUELLE'),
      pensionRecue: getIndicator('PANEL_4', 'PENSION_RECUE'),
    );
  }
}

// Modèle pour les activités récentes
class RecentActivityModel {
  final int id;
  final int adherantId;
  final String? dateVersement;
  final double montant;
  final String statut;
  final String type;
  final String typeTransaction;

  RecentActivityModel({
    required this.id,
    required this.adherantId,
    this.dateVersement,
    required this.montant,
    required this.statut,
    required this.type,
    required this.typeTransaction,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'] as int,
      adherantId: json['adherantId'] as int,
      dateVersement: json['dateVersement'] as String?,
      montant: (json['montant'] as num).toDouble(),
      statut: json['statut'] as String,
      type: json['type'] as String,
      typeTransaction: json['typeTransaction'] as String,
    );
  }

  DateTime get date {
    if (dateVersement == null || dateVersement!.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(dateVersement!);
    } catch (e) {
      return DateTime.now();
    }
  }

  //Statut normalisé : gère "Payé", "Paye", "PAYE", "Actif"
  bool get isPaid {
    final s = statut.toLowerCase().replaceAll('é', 'e').trim();
    return s == 'paye' || s == 'actif';
  }
}