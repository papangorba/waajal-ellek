import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../models/cotisation_model.dart';
import '../services/connectivity_service.dart';
import '../services/cotisation_service.dart';
import '../utils/currency_formatter.dart';

class CotisationsScreen extends StatefulWidget {
  const CotisationsScreen({super.key});

  @override
  State<CotisationsScreen> createState() => _CotisationsScreenState();
}

class _CotisationsScreenState extends State<CotisationsScreen> {
  List<Cotisation> _cotisations = [];
  bool _isLoading = true;
  String _filterMonth = 'Tous';
  List<String> _monthFilters = [];
  String? _errorMessage;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _generateMonthFilters();
    _loadCotisations();
  }

  void _generateMonthFilters() {
    _monthFilters = ['Tous'];
    DateTime now = DateTime.now();
    for (int i = 1; i <= 3; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      _monthFilters.add(DateFormat('MMMM yyyy', 'fr_FR').format(month));
    }
    _monthFilters.add('Autres mois');
  }

  Future<void> _loadCotisations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final connectivityService =
      Provider.of<ConnectivityService>(context, listen: false);

      final token = authProvider.accessToken;
      final userId = authProvider.userId;
      final adherantId = authProvider.adherantId;

      if (token == null || userId == null || adherantId == null) {
        throw Exception("Token manquant ou utilisateur non connecté.");
      }

      _isOffline = !await connectivityService.checkConnection();


      final allCotisations = await CotisationService.getCotisations(
        accessToken: token,
        userId: userId.toString(),
        adherantId: adherantId,
        connectivityService: connectivityService,
      );

      //Ce que l'API retourne
      print('Total cotisations reçues: ${allCotisations.length}');
      for (var c in allCotisations) {
        print('  → id:${c.id} | adherantId:${c.adherantId} | statut:${c.statut} | date:${c.dateVersement}');
      }

      //Après filtre adherantId
      final userCotisations =
      allCotisations.where((c) => c.adherantId == adherantId).toList();
      print('Après filtre adherantId ($adherantId): ${userCotisations.length}');

      //Après filtre statut
      final filtered = userCotisations.where((c) {
        if (c.statut == null) return false;
        final statut = c.statut!.toLowerCase().replaceAll('é', 'e').trim();
        print('  statut brut: "${c.statut}" → normalisé: "$statut"');
        return statut == 'paye' || statut == 'en attente';
      }).toList();
      print('Après filtre statut: ${filtered.length}');

      _cotisations = filtered;

      // filtre mois (inchangé)
      if (_filterMonth != 'Tous' && _filterMonth != 'Autres mois') {
        _cotisations = _cotisations.where((c) {
          if (c.dateVersement == null) return false;
          try {
            final cDate = DateTime.parse(c.dateVersement!);
            return DateFormat('MMMM yyyy', 'fr_FR').format(cDate) == _filterMonth;
          } catch (e) {
            return false;
          }
        }).toList();
        print('Après filtre mois ($_filterMonth): ${_cotisations.length}');
      }

      _cotisations.sort((a, b) {
        final dateA = a.dateVersement != null ? DateTime.tryParse(a.dateVersement!) : null;
        final dateB = b.dateVersement != null ? DateTime.tryParse(b.dateVersement!) : null;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Erreur: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Erreur de chargement'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _loadCotisations,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectHistoricalMonth() async {
    DateTime now = DateTime.now();
    DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, 1);

    List<String> oldMonths = [];
    DateTime date = threeMonthsAgo.subtract(const Duration(days: 30));
    while (date.year >= 2000) {
      oldMonths.add(DateFormat('MMMM yyyy', 'fr_FR').format(date));
      date = DateTime(date.year, date.month - 1, 1);
    }

    String? picked = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Sélectionner un mois'),
          children: oldMonths
              .map((month) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, month),
            child: Text(month),
          ))
              .toList(),
        );
      },
    );

    if (picked != null) {
      setState(() => _filterMonth = picked);
      _loadCotisations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bannière offline
        if (_isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange[100],
            child: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Mode hors ligne',
                    style: TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadCotisations,
                ),
              ],
            ),
          ),

        // FILTRES
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _monthFilters.map((label) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: label,
                    isSelected: _filterMonth == label,
                    onTap: () async {
                      if (label == 'Autres mois') {
                        await _selectHistoricalMonth();
                      } else {
                        setState(() => _filterMonth = label);
                        _loadCotisations();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // LISTE
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadCotisations,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          )
              : _cotisations.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _filterMonth == 'Tous'
                      ? 'Aucune cotisation disponible'
                      : 'Aucune cotisation pour $_filterMonth',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadCotisations,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cotisations.length,
              itemBuilder: (_, i) {
                final c = _cotisations[i];
                DateTime? date;
                if (c.dateVersement != null) {
                  try {
                    date = DateTime.parse(c.dateVersement!);
                  } catch (e) {
                    print(
                        'Erreur chargement date: ${c.dateVersement}');
                  }
                }

                final statutNorm = c.statut
                    ?.toLowerCase()
                    .replaceAll('é', 'e')
                    .trim() ??
                    '';
                final isPaid = statutNorm == 'paye';
                final statusColor =
                isPaid ? Colors.green : Colors.orange;
                final statusBgColor = isPaid
                    ? Colors.green[100]
                    : Colors.orange[100];
                final statusLabel =
                isPaid ? 'PAYÉ' : 'EN ATTENTE';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isPaid
                            ? Icons.check_circle
                            : Icons.hourglass_empty,
                        color: statusColor,
                        size: 32,
                      ),
                    ),
                    title: Text(
                      CurrencyFormatter.format(c.montant),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        date != null
                            ? 'Date: ${DateFormat('dd MMMM yyyy', 'fr_FR').format(date)} • Type: ${c.typeCotisation}'
                            : 'Type: ${c.typeCotisation}',
                        style:
                        TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.blue.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}