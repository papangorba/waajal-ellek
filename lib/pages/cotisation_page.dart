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
  final CotisationService _apiService = CotisationService();

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
      _monthFilters.add(DateFormat('MMMM yyyy').format(month));
    }
    _monthFilters.add('Autres mois'); // sélection mois dqns historique
  }

  Future<void> _loadCotisations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer le token depuis le Provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
      final token = authProvider.accessToken;
      final userId = authProvider.userId;

      if (token == null || userId == null) {
        throw Exception("Token manquant ou userid. Veuillez vous reconnecter.");
      }
      _isOffline = !await connectivityService.checkConnection();

      // Appel de l'API avec le token
      final allCotisations = await CotisationService.getCotisations(
        accessToken: token,
        userId: userId,
        connectivityService: connectivityService,);

      final paidCotisations = allCotisations
          .where((c) => c.statut.toUpperCase() == 'PAYE')
          .toList();

      if (_filterMonth == 'Tous') {
        _cotisations = paidCotisations;
      } else if (_filterMonth == 'Autres mois') {
        _cotisations = [];
      } else {
        _cotisations = paidCotisations.where((c) {
          try {
            final cDate = DateTime.parse(c.dateVersement);
            return DateFormat('MMMM yyyy', 'fr_FR').format(cDate) == _filterMonth;
          } catch (e) {
            print('Erreur parsing date: ${c.dateVersement}');
            return false;
          }
        }).toList();
      }

      _cotisations.sort((a, b) {
        try {
          return DateTime.parse(b.dateVersement)
              .compareTo(DateTime.parse(a.dateVersement));
        } catch (e) {
          return 0;
        }
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectHistoricalMonth() async {
    DateTime now = DateTime.now();
    DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, 1);

    List<String> oldMonths = [];
    DateTime date = threeMonthsAgo.subtract(const Duration(days: 30));
    while (date.year >= 2000) {
      oldMonths.add(DateFormat('MMMM yyyy').format(date));
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
                    'Mode hors ligne ',
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
                bool isSelected = _filterMonth == label;
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
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

                try {
                  date = DateTime.parse(c.dateVersement);
                } catch (e) {
                  print('Erreur parsing date: ${c.dateVersement}');
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
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
                            ? 'Mois: ${DateFormat('dd MMMM yyyy', 'fr_FR').format(date)} • Type: ${c.typeCotisation}'
                            : c.typeCotisation,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PAYÉ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
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