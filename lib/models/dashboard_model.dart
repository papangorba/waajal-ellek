// Indicateur générique — affiche label + value tels quels
class PanelIndicator {
  final String key;
  final String label;
  final String value;

  PanelIndicator({
    required this.key,
    required this.label,
    required this.value,
  });

  factory PanelIndicator.fromJson(Map<String, dynamic> json) {
    return PanelIndicator(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}

// Panel générique — affiche label + value + indicators dans l'ordre reçu
class DashboardPanel {
  final String key;
  final String label;
  final String value;
  final List<PanelIndicator> indicators;

  DashboardPanel({
    required this.key,
    required this.label,
    required this.value,
    required this.indicators,
  });

  factory DashboardPanel.fromJson(Map<String, dynamic> json) {
    final rawIndicators = json['indicators'] as List<dynamic>? ?? [];
    return DashboardPanel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      indicators: rawIndicators
          .map((e) => PanelIndicator.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Modèle dashboard — liste de panels dans l'ordre reçu
class DashboardStatsModel {
  final List<DashboardPanel> panels;

  DashboardStatsModel({required this.panels});

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final rawPanels = json['panels'] as List<dynamic>? ?? [];
    return DashboardStatsModel(
      panels: rawPanels
          .map((e) => DashboardPanel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Modèle activités récentes — INCHANGÉ
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
    } catch (_) {
      return DateTime.now();
    }
  }

  bool get isPaid {
    final s = statut.toLowerCase().replaceAll('é', 'e').trim();
    return s == 'paye' || s == 'actif';
  }
}