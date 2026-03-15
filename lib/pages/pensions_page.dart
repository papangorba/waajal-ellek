import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../models/pension_model.dart';
import '../services/connectivity_service.dart';
import '../services/pension_service.dart';
import '../utils/currency_formatter.dart';

class PensionsScreen extends StatefulWidget {
  const PensionsScreen({super.key});

  @override
  State<PensionsScreen> createState() => _PensionsScreenState();
}

class _PensionsScreenState extends State<PensionsScreen> {
  List<PensionModel> _pensions = [];
  bool _isLoading = true;
  String _filterMonth = 'Tous';
  List<String> _monthFilters = [];
  String? _errorMessage;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _generateMonthFilters();
    _loadPensions();
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

  Future<void> _loadPensions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

      final token = authProvider.accessToken;
      final userId = authProvider.userId?.toString();
      final adherantId = authProvider.adherantId;

      if (token == null || userId == null || adherantId == null) {
        throw Exception("Utilisateur non authentifié");
      }

      // Vérifier la connexion
      _isOffline = !await connectivityService.checkConnection();

      final allPensions = await PensionService.getPensions(
        accessToken: token,
        userId: userId,
        adherantId: adherantId,
        connectivityService: connectivityService,
      );

      final paidPensions = allPensions
          .where((p) => p.isPaid)
          .toList();

      if (_filterMonth == 'Tous') {
        _pensions = paidPensions;
      } else if (_filterMonth == 'Autres mois') {
        _pensions = [];
      } else {
        _pensions = paidPensions.where((p) {
          try {
            final pDate = p.date;
            return DateFormat('MMMM yyyy', 'fr_FR').format(pDate) == _filterMonth;
          } catch (e) {
            return false;
          }
        }).toList();
      }

      _pensions.sort((a, b) => b.date.compareTo(a.date));

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Erreur pensions: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Erreur de chargement des pensions'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _loadPensions,
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
    DateTime date = DateTime(now.year, now.month - 4, 1);

    List<String> months = [];
    while (date.year >= 2020) {
      months.add(DateFormat('MMMM yyyy', 'fr_FR').format(date));
      date = DateTime(date.year, date.month - 1, 1);
      if (months.length >= 36) break; // Limiter à 3 ans
    }

    String? picked = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Sélectionner un mois'),
        children: months.map((m) => SimpleDialogOption(
          child: Text(m),
          onPressed: () => Navigator.pop(context, m),
        )).toList(),
      ),
    );

    if (picked != null) {
      setState(() => _filterMonth = picked);
      _loadPensions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Bannière offline
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
                  onPressed: _loadPensions,
                ),
              ],
            ),
          ),
        //FILTRES
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
                        _loadPensions();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        //LISTE
        Expanded(
          child: _isLoading
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement des pensions...'),
              ],
            ),
          )
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
                    onPressed: _loadPensions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          )
              : _pensions.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _filterMonth == 'Tous'
                      ? 'Aucune pension disponible'
                      : 'Aucune pension pour $_filterMonth',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadPensions,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pensions.length,
              itemBuilder: (_, i) {
                final pension = _pensions[i];
                DateTime? date;

                try {
                  date = pension.date;
                } catch (e) {
                  print('Erreur parsing date pension: ${pension.dateVersement}');
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
                      CurrencyFormatter.format(pension.montant),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (date != null)
                            Text(
                              'Mois: ${DateFormat('dd MMMM yyyy', 'fr_FR').format(date)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            'Type: ${pension.typePension}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
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