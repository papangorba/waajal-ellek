import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../models/cotisation_model.dart';
import '../services/data_service.dart';
import '../utils/date_formatter.dart';
import '../utils/currency_formatter.dart';

class CotisationsScreen extends StatefulWidget {
  const CotisationsScreen({super.key});

  @override
  State<CotisationsScreen> createState() => _CotisationsScreenState();
}

class _CotisationsScreenState extends State<CotisationsScreen> {
  final DataService _dataService = DataService();
  List<CotisationModel> _cotisations = [];
  bool _isLoading = true;
  String _filterStatus = 'tous';

  @override
  void initState() {
    super.initState();
    _loadCotisations();
  }

  Future<void> _loadCotisations() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;

      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 500));

        final allCotisations = _dataService.getCotisations(userId);

        if (_filterStatus == 'tous') {
          _cotisations = allCotisations;
        } else {
          _cotisations = allCotisations
              .where((c) => c.statut == _filterStatus)
              .toList();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                child: _FilterChip(
                  label: 'Tous',
                  isSelected: _filterStatus == 'tous',
                  onTap: () {
                    setState(() => _filterStatus = 'tous');
                    _loadCotisations();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterChip(
                  label: 'Payé',
                  isSelected: _filterStatus == 'paye',
                  onTap: () {
                    setState(() => _filterStatus = 'paye');
                    _loadCotisations();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterChip(
                  label: 'En attente',
                  isSelected: _filterStatus == 'en_attente',
                  onTap: () {
                    setState(() => _filterStatus = 'en_attente');
                    _loadCotisations();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _cotisations.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune cotisation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadCotisations,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cotisations.length,
              itemBuilder: (context, index) {
                final cotisation = _cotisations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cotisation.isPaid
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        cotisation.isPaid
                            ? Icons.check_circle
                            : Icons.pending,
                        color: cotisation.isPaid
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    title: Text(
                      CurrencyFormatter.format(cotisation.montant),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.format(cotisation.dateCotisation),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cotisation.pointsAcquis} points',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        cotisation.statut.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: cotisation.isPaid
                          ? Colors.green[100]
                          : Colors.orange[100],
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
