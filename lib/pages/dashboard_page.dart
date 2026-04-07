import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waajal_elek/config/theme.dart';
import 'package:waajal_elek/pages/similation_page.dart';
import '../models/dashboard_model.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/connectivity_service.dart';
import '../services/dashboard_service.dart';
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
      _loadDashboardData();
    } else {
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

    if (_errorMessage != null &&
        !_errorMessage!.contains('Session expirée')) {
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
                    'Gardez un œil sur votre compte',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLastSyncButton(),
                  const SizedBox(height: 20),

                  // GRID générique — s'adapte à n'importe quel nombre de panels
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: _stats!.panels.length,
                    itemBuilder: (context, index) {
                      return _PanelCard(panel: _stats!.panels[index]);
                    },
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

                  // ── Section activités ← SEUL CHANGEMENT ICI
                  _ActivitySection(
                    activities: _recentActivities,
                    onVoirTout: () {
                      // TODO: naviguer vers la page complète
                    },
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  //SYNC BUTTON

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



  // ACTIVITY CARD
}

// _ActivitySection — affichage paginé avec "Voir plus" et "Voir moins"

class _ActivitySection extends StatefulWidget {
  final List<RecentActivityModel> activities;
  final VoidCallback? onVoirTout;

  const _ActivitySection({
    required this.activities,
    this.onVoirTout,
  });

  @override
  State<_ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<_ActivitySection> {
  static const int _pageSize = 3;
  int _visibleCount = _pageSize;

  List<RecentActivityModel> get _visible =>
      widget.activities.take(_visibleCount).toList();

  bool get _hasMore => _visibleCount < widget.activities.length;

  // "Voir moins" visible uniquement si on a chargé plus que la première page
  bool get _canCollapse => _visibleCount > _pageSize;

  void _loadMore() => setState(() => _visibleCount += _pageSize);

  void _collapse() => setState(() => _visibleCount = _pageSize);

  @override
  void didUpdateWidget(_ActivitySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activities != widget.activities) {
      _visibleCount = _pageSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        _buildList(),
        const SizedBox(height: 8),
        _buildButtons(),
      ],
    );
  }

  //  En-tête

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Activité récente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.activities.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        if (widget.onVoirTout != null)
          TextButton(
            onPressed: widget.onVoirTout,
            child: const Text('Voir tout'),
          ),
      ],
    );
  }

  //  Liste

  Widget _buildList() {
    final items = _visible;

    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aucune activité récente'),
        ),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final isLast = entry.key == items.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: _ActivityCard(activity: entry.value),
        );
      }).toList(),
    );
  }

  //  Boutons "Voir plus" / "Voir moins"

  Widget _buildButtons() {
    // Ni l'un ni l'autre → rien à afficher
    if (!_hasMore && !_canCollapse) return const SizedBox();

    final remaining = widget.activities.length - _visibleCount;
    final nextBatch = remaining > _pageSize ? _pageSize : remaining;

    return Row(
      children: [
        // Bouton "Voir plus" — visible si des éléments restent cachés
        if (_hasMore)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _loadMore,
              icon: const Icon(Icons.expand_more, size: 18),
              label: Text('Voir $nextBatch de plus · $remaining restants'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        // Séparateur entre les deux boutons
        if (_hasMore && _canCollapse) const SizedBox(width: 8),

        // Bouton "Voir moins" — visible si on a dépassé la première page
        if (_canCollapse)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _collapse,
              icon: const Icon(Icons.expand_less, size: 18),
              label: const Text('Voir moins'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.grey.shade500,
                side: BorderSide(color: Colors.grey.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// _ActivityCard — carte individuelle

class _ActivityCard extends StatelessWidget {
  final RecentActivityModel activity;

  const _ActivityCard({required this.activity});

  static Color _colorForType(String type) {
    switch (type.toUpperCase()) {
      case 'COTISATION':
        return Colors.blue;
      case 'PENSION':
        return Colors.green;
      case 'RACHAT':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'COTISATION':
        return Icons.arrow_upward;
      case 'PENSION':
        return Icons.arrow_downward;
      case 'RACHAT':
        return Icons.sync_alt;
      default:
        return Icons.help_outline;
    }
  }

  static String _labelForType(String type) {
    switch (type.toUpperCase()) {
      case 'COTISATION':
        return 'Cotisation';
      case 'PENSION':
        return 'Pension';
      case 'RACHAT':
        return 'Rachat';
      default:
        return type;
    }
  }

  static String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Date inconnue';
    try {
      final d = DateTime.parse(raw).toLocal();
      return "${d.day.toString().padLeft(2, '0')}/"
          "${d.month.toString().padLeft(2, '0')}/"
          "${d.year}";
    } catch (_) {
      return 'Date invalide';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(activity.type);
    final icon = _iconForType(activity.type);
    final typeLabel = _labelForType(activity.type);
    final statusColor = activity.isPaid ? Colors.green : Colors.orange;

    return Card(
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          CurrencyFormatter.format(activity.montant),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$typeLabel • ${activity.typeTransaction}\n'
              '${_formatDate(activity.dateVersement)}',
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


//PANEL CARD — générique, aucune clé codée en dur

class _PanelCard extends StatelessWidget {
  final DashboardPanel panel;

  // Couleurs et icônes par position dans la liste (index 0, 1, 2, 3...)
  static const List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.red,
  ];

  static const List<IconData> _icons = [
    Icons.account_balance_wallet,
    Icons.trending_up,
    Icons.calendar_month,
    Icons.verified,
    Icons.trending_up,
    Icons.bar_chart,
  ];

  const _PanelCard({required this.panel});

  // Extrait l'index depuis "PANEL_1" → 0, "PANEL_2" → 1, etc.
  int get _colorIndex {
    final match = RegExp(r'\d+').firstMatch(panel.key);
    final n = int.tryParse(match?.group(0) ?? '1') ?? 1;
    return (n - 1).clamp(0, _colors.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final color = _colors[_colorIndex];
    final icon = _icons[_colorIndex];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Icône + label du panel
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  panel.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Valeur principale — telle quelle, sans formatage
          Text(
            panel.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 8),

          // ── Indicators dans l'ordre reçu — label + value tels quels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: panel.indicators.map((indicator) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      indicator.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      indicator.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

