import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:waajal_elek/config/theme.dart';
import 'package:waajal_elek/pages/similation_page.dart';
import '../models/dashboard_model.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/connectivity_service.dart';
import '../services/dashboard_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_activity_card.dart';
import '../utils/currency_formatter.dart';
import 'authentification/login_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardStatsModel? _stats;
  List<RecentActivityModel> _recentActivities = [];
  bool _isLoading = true;
  DateTime? _lastSyncAt;
  String? _errorMessage;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final connectivityService = context.read<ConnectivityService>();

      final accessToken = authProvider.accessToken;
      final userId = authProvider.userId?.toString();

      if (accessToken == null || userId == null) {
        throw Exception("Session expirée. Veuillez vous reconnecter.");
      }

      _isOffline = !await connectivityService.checkConnection();

      final stats = await DashboardService.getDashboardStats(
        accessToken: accessToken,
        userId: userId,
        connectivityService: connectivityService,
      );

      final activities = await DashboardService.getRecentActivities(
        accessToken: accessToken,
        userId: userId,
        connectivityService: connectivityService,
      );

      final lastSync = await DashboardService.getLastDashboardSync();

      setState(() {
        _stats = stats;
        _recentActivities = activities;
        _lastSyncAt = lastSync;
      });
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Erreur dashboard: $e');

      if (_errorMessage?.contains('Session expirée') == true) {
        _handleSessionExpired();
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Erreur de chargement'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _loadDashboardData,
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

  void _handleSessionExpired() async {
    final authProvider = context.read<AuthProvider>();
    final refreshed = await authProvider.refreshAccessToken();

    if (refreshed) {
      print('Token rafraîchi, rechargement du dashboard...');
      _loadDashboardData();
    } else {
      print('Échec de chargement, déconnexion...');
      await authProvider.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expirée. Veuillez vous reconnecter.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userProfile;

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement du tableau de bord...'),
          ],
        ),
      );
    }

    if (_errorMessage != null && !_errorMessage!.contains('Session expirée')) {
      return Center(
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
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_stats == null) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

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
                  onPressed: _loadDashboardData,
                ),
              ],
            ),
          ),

        Expanded(
          child: RefreshIndicator(
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
                  const SizedBox(height: 12),
                  _buildLastSyncButton(),
                  const SizedBox(height: 20),

                  // GRID 2 PAR LIGNE
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      InfoStatCard(
                        title: 'Capital Retraite',
                        mainValue: _stats!.capitalRetraite,
                        icon: Icons.account_balance_wallet,
                        color: Colors.blue,
                        isCurrency: true,
                        details: [
                          {
                            'label': 'Cotisation mensuelle',
                            'value': _stats!.cotisationMensuelle,
                            'isCurrency': true,
                          },
                          {
                            'label': 'Total cotisé',
                            'value': _stats!.totalCotisations,
                            'isCurrency': true,
                          },
                        ],
                      ),
                      InfoStatCard(
                        title: 'Pension Estimée',
                        mainValue: _stats!.pensionEstimee,
                        icon: Icons.verified,
                        color: Colors.green,
                        isCurrency: true,
                        details: [
                          {
                            'label': 'Taux de remplacement',
                            'value': (_stats!.tauxRemplacement * 100).toInt(),
                            'suffix': '%',
                          },
                          {
                            'label': 'Projection à 5 ans',
                            'value': _stats!.projection5ans,
                            'isCurrency': true,
                          },
                        ],
                      ),
                      InfoStatCard(
                        title: 'Années de Service',
                        mainValue: _stats!.anneesService,
                        suffix: 'ans',
                        icon: Icons.calendar_month,
                        color: Colors.purple,
                        details: [
                          {
                            'label': 'Âge actuel',
                            'value': _stats!.ageActuel,
                            'suffix': 'ans',
                          },
                          {
                            'label': 'Avant retraite',
                            'value': _stats!.anneesAvantRetraite,
                            'suffix': 'ans',
                          },
                        ],
                      ),
                      InfoStatCard(
                        title: 'Intérêts Cumulés',
                        mainValue: _stats!.interetsCumules,
                        icon: Icons.trending_up,
                        color: Colors.orange,
                        isCurrency: true,
                        details: [
                          {
                            'label': 'Taux intérêt',
                            'value': (_stats!.tauxInteret * 100)
                                .toStringAsFixed(1),
                            'suffix': '%',
                          },
                          {
                            'label': 'Projection 10 ans',
                            'value': _stats!.projection10ans,
                            'isCurrency': true,
                          },
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SimulationScreen()),
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
                        child: _buildActivityCard(activity),
                      );
                    })),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastSyncButton() {
    if (_lastSyncAt == null) return const SizedBox();

    final localSync = _lastSyncAt!.toLocal();
    final formattedDate =
        "${localSync.day.toString().padLeft(2, '0')}/"
        "${localSync.month.toString().padLeft(2, '0')}/"
        "${localSync.year} à "
        "${localSync.hour.toString().padLeft(2, '0')}:"
        "${localSync.minute.toString().padLeft(2, '0')}";

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loadDashboardData,
        icon: const Icon(Icons.sync, color: Colors.white, size: 20),
        label: Text(
          "Dernière synchronisation : $formattedDate",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(RecentActivityModel activity) {
    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    String formatDate(String? raw) {
      if (raw == null || raw.isEmpty) return 'Date inconnue';
      try {
        final d = DateTime.parse(raw).toLocal();
        return "${d.day.toString().padLeft(2, '0')}/"
            "${d.month.toString().padLeft(2, '0')}/"
            "${d.year}";
      } catch (e) {
        return 'Date invalide';
      }
    }

    switch (activity.type) {
      case 'COTISATION':
        typeColor = Colors.blue;
        typeIcon = Icons.arrow_upward;
        typeLabel = 'Cotisation';
        break;
      case 'PENSION':
        typeColor = Colors.green;
        typeIcon = Icons.arrow_downward;
        typeLabel = 'Pension';
        break;
      case 'RACHAT':
        typeColor = Colors.orange;
        typeIcon = Icons.sync_alt;
        typeLabel = 'Rachat';
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.help_outline;
        typeLabel = activity.type;
    }

    //isPaid gère "Payé", "Paye", "Actif"
    final statusColor = activity.isPaid ? Colors.green : Colors.orange;

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          CurrencyFormatter.format(activity.montant),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$typeLabel • ${activity.typeTransaction}\n${formatDate(activity.dateVersement)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            activity.statut,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class InfoStatCard extends StatelessWidget {
  final String title;
  final dynamic mainValue;
  final String? suffix;
  final bool isCurrency;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> details;

  const InfoStatCard({
    super.key,
    required this.title,
    required this.mainValue,
    this.suffix,
    this.isCurrency = false,
    required this.icon,
    required this.color,
    required this.details,
  });

  String _formatValue(dynamic value, String? suffix, bool isCurrency) {
    if (isCurrency) {
      if (value is double) return CurrencyFormatter.format(value);
      if (value is int) return CurrencyFormatter.format(value.toDouble());
      if (value is num) return CurrencyFormatter.format(value.toDouble());
    }
    if (value is int) return suffix != null ? '$value $suffix' : value.toString();
    if (value is String) return suffix != null ? '$value $suffix' : value;
    if (value is double) {
      return suffix != null
          ? '${value.toStringAsFixed(1)} $suffix'
          : value.toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AutoScrollText(
            text: _formatValue(mainValue, suffix, isCurrency),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            height: 22,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: details.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoScrollText(
                          text: e['label']!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AutoScrollText(
                          text: _formatValue(
                            e['value'],
                            e['suffix'],
                            e['isCurrency'] == true,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AutoScrollText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double height;

  const AutoScrollText({
    super.key,
    required this.text,
    this.style,
    this.height = 18,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: double.infinity);

        final isOverflowing = textPainter.width > constraints.maxWidth;

        if (!isOverflowing) {
          return Text(text, style: style, maxLines: 1);
        }

        return SizedBox(
          height: height,
          child: Marquee(
            text: text,
            style: style,
            blankSpace: 30,
            velocity: 25,
            pauseAfterRound: const Duration(seconds: 1),
            startPadding: 10,
          ),
        );
      },
    );
  }
}