import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waajal_elek/pages/similation_page.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/data_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_activity_card.dart';
import '../utils/currency_formatter.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DataService _dataService = DataService();
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;

      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 500));

        _stats = _dataService.getDashboardStats(userId);
        _recentActivities = _dataService.getRecentActivities(userId);
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
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userProfile;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${user?.prenom ?? ""}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Voici un résumé de votre compte',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Cotisations',
                    value: CurrencyFormatter.format(_stats?['totalCotisations'] ?? 0.0),
                    icon: Icons.account_balance_wallet,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Points Accumulés',
                    value: '${_stats?['totalPoints'] ?? 0}',
                    icon: Icons.stars,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Pension Mensuelle',
                    value: CurrencyFormatter.format(_stats?['montantPension'] ?? 0.0),
                    icon: Icons.payments,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Cotisations',
                    value: '${_stats?['nombreCotisations'] ?? 0}',
                    icon: Icons.receipt,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SimulationScreen()),
                  );
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Simuler ma pension'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activité Récente',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentActivities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucune activité récente'),
                ),
              )
            else
              ...(_recentActivities.map((activity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RecentActivityCard(activity: activity),
                );
              })),
          ],
        ),
      ),
    );
  }
}
