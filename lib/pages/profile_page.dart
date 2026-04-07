import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../config/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRefreshing = false;
  DateTime? _lastRefreshed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocalProfile();
    });
    // depuis api
    _refreshProfileFromApi();
  }

  void _loadLocalProfile() {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.userProfile != null) {
      userProvider.setUserProfile(authProvider.userProfile);
    }
  }

  Future<void> _refreshProfileFromApi() async {
    setState(() => _isRefreshing = true);
    try {
      // final userProvider = context.read<UserProvider>();
      // await userProvider.fetchUserProfile();
      await Future.delayed(const Duration(milliseconds: 600)); // simulé
      setState(() => _lastRefreshed = DateTime.now());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de mettre à jour le profil.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  String _formatLastRefreshed() {
    if (_lastRefreshed == null) return '';
    final h = _lastRefreshed!.hour.toString().padLeft(2, '0');
    final m = _lastRefreshed!.minute.toString().padLeft(2, '0');
    return 'Données mises à jour à ${h}h$m';
  }




  void _callSupport() async {
    final uri = Uri.parse('tel:${SupportConstants.phoneNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _whatsappSupport() async {
    final uri = Uri.parse(
      'https://wa.me/${SupportConstants.whatsappNumber}?text=Bonjour, j’ai besoin d’assistance.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Aide et support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Appeler le support'),
                onTap: () {
                  Navigator.pop(context);
                  _callSupport();
                },
              ),

              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Color(0xFF25D366),
                ),
                title: const Text('Contacter via WhatsApp'),
                onTap: () {
                  Navigator.pop(context);
                  _whatsappSupport();
                },
              ),


              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Annuler'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userProfile;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
        onRefresh: _refreshProfileFromApi,
      child:SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔵 HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: Text(
                      user.prenom.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    user.nomComplet,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 8),

                  Chip(
                    label: Text(user.statut.toUpperCase()),
                    backgroundColor: user.isRetraite
                        ? Colors.orange[100]
                        : Colors.green[100],
                  ),
                ],
              ),
            ),
            //BARRE DE RAFRAÎCHISSEMENT ────────────────────────────────
            if (_isRefreshing || _lastRefreshed != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[100]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    if (_isRefreshing)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.check_circle_outline,
                          size: 14, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _isRefreshing
                          ? 'Mise à jour en cours...'
                          : _formatLastRefreshed(),
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),

            const SizedBox(height:16),

            //INFOS
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informations personnelles",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),

                    _InfoTile(
                      icon: Icons.badge,
                      iconColor: Colors.blue,
                      iconBg: Colors.blue.shade50,
                      label: 'Matricule',
                      value: user.matricule,
                    ),
                    _InfoTile(
                      icon: Icons.military_tech,
                      iconColor: Colors.amber.shade800,
                      iconBg: Colors.amber.shade50,
                      label: 'Grade',
                      value: AppConstants.militaryRanks[user.grade] ?? user.grade,
                    ),

                    if (user.telephone != null)
                      _InfoTile(
                        icon: Icons.phone,
                        iconColor: Colors.green,
                        iconBg: Colors.green.shade50,
                        label: 'Téléphone',
                        value: user.telephone!,
                      ),

                    if (user.dateNaissance != null)
                      _InfoTile(
                        icon: Icons.cake,
                        iconColor: Colors.blue,
                        iconBg: Colors.blue.shade50,
                        label: 'Date de naissance',
                        value: user.dateNaissance!,
                      ),

                    if (user.dateEngagement != null)
                      _InfoTile(
                        icon: Icons.work,
                        iconColor: Colors.green,
                        iconBg: Colors.green.shade50,
                        label: 'Date d\'engagement',
                        value: user.dateEngagement!,
                      ),

                    if (user.dateRetraite != null)
                      _InfoTile(
                        icon: Icons.event,
                        iconColor: Colors.orange,
                        iconBg: Colors.orange.shade50,
                        label: 'Date de retraite',
                        value: user.dateRetraite!,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ⚙️ ACTIONS
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.lock,
                    iconBg: Colors.green.shade50,
                    iconColor: Colors.green,
                    title: 'Changer le mot de passe',
                    subtitle: 'Sécurisez votre compte régulièrement',
                    onTap: () => {},
                  ),

                  const Divider(height: 1),

                  _ActionTile(
                    icon: Icons.support_agent,
                    iconBg: Colors.blue.shade50,
                    iconColor: Colors.blue,
                    title: 'Aide et support',
                    subtitle: 'Appel ou WhatsApp disponible',
                    onTap: () => _showSupportOptions(context),
                  ),
                  _ActionTile(
                    icon: Icons.language,
                    iconBg: Colors.orange.shade50,
                    iconColor: Colors.orange,
                    title: 'Langue',
                    subtitle: 'Français',
                    onTap: () {
                      //sélection de langue
                    },
                  ),
                ],
              ),
            ),
            // ── VERSION ──────────────────────────────────────────────────
            const SizedBox(height: 10),
            Text(
              'Version 2.1.0 · Waajal Eleek',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ) ,
    );

  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

