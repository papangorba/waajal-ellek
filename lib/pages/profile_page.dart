import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../config/constants.dart';
import '../utils/date_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    // affiche le profil local(sha...)
    _loadLocalProfile();
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

  void _refreshProfileFromApi() async {
    final userProvider = context.read<UserProvider>();
    // si on veux appeler le backend pour rafraîchir les données
    // par exemple userProvider.fetchUserProfile();
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user.prenom.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.nomComplet,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(user.statut.toUpperCase()),
            backgroundColor: user.isRetraite
                ? Colors.orange[100]
                : Colors.green[100],
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations personnelles',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 24),
                  _InfoTile(
                    icon: Icons.badge,
                    label: 'Matricule',
                    value: user.matricule,
                  ),
                  _InfoTile(
                    icon: Icons.military_tech,
                    label: 'Grade',
                    value: AppConstants.militaryRanks[user.grade] ?? user.grade,
                  ),
                  if (user.telephone != null)
                    _InfoTile(
                      icon: Icons.phone,
                      label: 'Téléphone',
                      value: user.telephone!,
                    ),
                  if (user.dateNaissance != null)
                    _InfoTile(
                      icon: Icons.cake,
                      label: 'Date de naissance',
                      value: user.dateNaissance! ,
                    ),
                  if (user.dateEngagement != null)
                    _InfoTile(
                      icon: Icons.work,
                      label: 'Date d\'engagement',
                      value: user.dateEngagement! ,
                    ),
                  if (user.dateRetraite != null)
                    _InfoTile(
                      icon: Icons.event,
                      label: 'Date de retraite',
                      value: user.dateRetraite!,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                //ListTile(
                //  leading: const Icon(Icons.edit),
                //  title: const Text('Modifier le profil'),
                //  trailing: const Icon(Icons.chevron_right),
                //  onTap: () {},
               // ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Changer le mot de passe'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Aide et support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSupportOptions(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('Télécharger mes données'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
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
