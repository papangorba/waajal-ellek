import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../models/pension_model.dart';
import '../services/data_service.dart';
import '../utils/date_formatter.dart';
import '../utils/currency_formatter.dart';

class PensionsScreen extends StatefulWidget {
  const PensionsScreen({super.key});

  @override
  State<PensionsScreen> createState() => _PensionsScreenState();
}

class _PensionsScreenState extends State<PensionsScreen> {
  final DataService _dataService = DataService();
  List<PensionModel> _pensions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPensions();
  }

  Future<void> _loadPensions() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;

      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 500));

        _pensions = _dataService.getPensions(userId);
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
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _pensions.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payments_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune pension',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos informations de pension apparaîtront ici',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        : RefreshIndicator(
      onRefresh: _loadPensions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pensions.length,
        itemBuilder: (context, index) {
          final pension = _pensions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pension.typePension.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: pension.isActive
                              ? Colors.green[50]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pension.statut.toUpperCase(),
                          style: TextStyle(
                            color: pension.isActive
                                ? Colors.green[700]
                                : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.attach_money,
                    label: 'Montant mensuel',
                    value: CurrencyFormatter.format(pension.montantMensuel),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.stars,
                    label: 'Total points',
                    value: '${pension.totalPoints}',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.date_range,
                    label: 'Date début',
                    value: DateFormatter.format(pension.dateDebut),
                  ),
                  if (pension.dateFin != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.event_busy,
                      label: 'Date fin',
                      value: DateFormatter.format(pension.dateFin!),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.trending_up,
                    label: 'Valeur du point',
                    value: CurrencyFormatter.format(pension.valeurPoint),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
