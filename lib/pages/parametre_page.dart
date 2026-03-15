import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkMode = false;
  bool _soundEnabled = true;
  bool _twoFactorEnabled = false;
  String _selectedLanguage = 'Français';
  String _autoLockDelay = '5 min';
  bool _autoLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          // ── Général ──────────────────────────────────────────
          const _SectionHeader(title: 'Général'),
          _SettingTile(
            icon: Icons.language,
            title: 'Langue',
            subtitle: _selectedLanguage,
            onTap: () => _showLanguageDialog(),
          ),
          _SettingTile(
            icon: Icons.brightness_6,
            title: 'Thème',
            subtitle: _darkMode ? 'Sombre' : 'Clair',
            onTap: () {
              setState(() => _darkMode = !_darkMode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thème ${_darkMode ? 'sombre' : 'clair'} activé'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Sons & Vibrations'),
            subtitle: const Text('Retour sonore et haptique'),
            value: _soundEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _soundEnabled = value);
            },
          ),
          const Divider(),

          // ── Notifications ─────────────────────────────────────
          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Activer les notifications'),
            subtitle: const Text('Recevoir les alertes importantes'),
            value: _notificationsEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _notificationsEnabled = value);
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _notificationsEnabled
                ? Column(
              children: [
                _SettingTile(
                  icon: Icons.campaign,
                  title: 'Types de notifications',
                  subtitle: 'Paiements, alertes, promotions',
                  onTap: () => _showNotifTypesDialog(),
                ),
                _SettingTile(
                  icon: Icons.do_not_disturb_on,
                  title: 'Ne pas déranger',
                  subtitle: 'Planifier le silence',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
                  ),
                ),
              ],
            )
                : const SizedBox.shrink(),
          ),
          const Divider(),

          // ── Sécurité ──────────────────────────────────────────
          const _SectionHeader(title: 'Sécurité'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Authentification biométrique'),
            subtitle: const Text('Utiliser l\'empreinte digitale'),
            value: _biometricEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _biometricEnabled = value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lock_clock),
            title: const Text('Verrouillage automatique'),
            subtitle: const Text('Verrouiller après inactivité'),
            value: _autoLockEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _autoLockEnabled = value);
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _autoLockEnabled
                ? _SettingTile(
              icon: Icons.timer,
              title: 'Délai de verrouillage',
              subtitle: _autoLockDelay,
              onTap: () => _showAutoLockDialog(),
            )
                : const SizedBox.shrink(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.verified_user),
            title: const Text('Double authentification'),
            subtitle: const Text('Code OTP à chaque connexion'),
            value: _twoFactorEnabled,
            onChanged: (value) => _toggle2FA(value),
          ),
          _SettingTile(
            icon: Icons.lock,
            title: 'Changer le mot de passe',
            onTap: () => _showChangePasswordDialog(),
          ),
          _SettingTile(
            icon: Icons.history,
            title: 'Historique de connexions',
            subtitle: 'Voir les accès récents',
            onTap: () => _showLoginHistory(),
          ),
          const Divider(),

          // ── À propos ──────────────────────────────────────────
          const _SectionHeader(title: 'À propos'),
          _SettingTile(
            icon: Icons.info,
            title: 'Version de l\'application',
            subtitle: '1.0.0',
            onTap: () {},
          ),
          _SettingTile(
            icon: Icons.star_rate,
            title: 'Noter l\'application',
            onTap: () => _showRateDialog(),
          ),
          _SettingTile(
            icon: Icons.support_agent,
            title: 'Contacter le support',
            subtitle: 'support@monapp.sn',
            onTap: () {},
          ),
          _SettingTile(
            icon: Icons.description,
            title: 'Conditions d\'utilisation',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ouverture des conditions...')),
            ),
          ),
          _SettingTile(
            icon: Icons.privacy_tip,
            title: 'Politique de confidentialité',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ouverture de la politique...')),
            ),
          ),
          const Divider(),

          // ── Déconnexion ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogues ────────────────────────────────────────────────────────

  void _showLanguageDialog() {
    final langs = ['Français', 'Wolof', 'English', 'Arabic'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: langs
              .map((lang) => RadioListTile<String>(
            title: Text(lang),
            value: lang,
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() => _selectedLanguage = value!);
              Navigator.pop(context);
            },
          ))
              .toList(),
        ),
      ),
    );
  }

  void _showAutoLockDialog() {
    final delays = ['1 min', '5 min', '15 min', '30 min', 'Jamais'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Délai de verrouillage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: delays
              .map((d) => RadioListTile<String>(
            title: Text(d),
            value: d,
            groupValue: _autoLockDelay,
            onChanged: (value) {
              setState(() => _autoLockDelay = value!);
              Navigator.pop(context);
            },
          ))
              .toList(),
        ),
      ),
    );
  }

  void _showNotifTypesDialog() {
    showDialog(
      context: context,
      builder: (context) => const _NotifTypesDialog(),
    );
  }

  void _toggle2FA(bool enable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(enable
            ? 'Activer la double authentification'
            : 'Désactiver la double authentification'),
        content: Text(enable
            ? 'Vous recevrez un code OTP à chaque connexion.'
            : 'Votre compte sera moins sécurisé. Continuer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _twoFactorEnabled = enable);
              Navigator.pop(context);
            },
            child: Text(enable ? 'Activer' : 'Désactiver'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PasswordField(
                controller: currentCtrl,
                label: 'Mot de passe actuel',
              ),
              const SizedBox(height: 16),
              _PasswordField(
                controller: newCtrl,
                label: 'Nouveau mot de passe',
                validator: (v) =>
                v != null && v.length < 6 ? 'Minimum 6 caractères' : null,
              ),
              const SizedBox(height: 16),
              _PasswordField(
                controller: confirmCtrl,
                label: 'Confirmer le mot de passe',
                validator: (v) => v != newCtrl.text
                    ? 'Les mots de passe ne correspondent pas'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Mot de passe modifié avec succès')),
                );
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showLoginHistory() {
    final sessions = [
      {'device': 'iPhone 15 Pro', 'date': "Aujourd'hui, 09:14", 'loc': 'Dakar'},
      {'device': 'Chrome / Windows', 'date': 'Hier, 18:30', 'loc': 'Thiès'},
      {'device': 'Samsung Galaxy', 'date': '3 mars, 11:05', 'loc': 'Mbour'},
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connexions récentes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sessions
              .map((s) => ListTile(
            leading: const Icon(Icons.devices),
            title: Text(s['device']!),
            subtitle: Text('${s['date']} · ${s['loc']}'),
            dense: true,
          ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showRateDialog() {
    int stars = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: const Text('Noter l\'application'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Votre avis nous aide à nous améliorer.'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (i) => GestureDetector(
                    onTap: () => setS(() => stars = i + 1),
                    child: Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Plus tard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Merci pour vos $stars étoile(s) !')),
                );
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
    }
  }
}

// ─── Widgets réutilisables ───────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

class _NotifTypesDialog extends StatefulWidget {
  const _NotifTypesDialog();

  @override
  State<_NotifTypesDialog> createState() => _NotifTypesDialogState();
}

class _NotifTypesDialogState extends State<_NotifTypesDialog> {
  bool _paiements = true;
  bool _alertes = true;
  bool _promotions = false;
  bool _systeme = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Types de notifications'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Paiements'),
            value: _paiements,
            onChanged: (v) => setState(() => _paiements = v),
            dense: true,
          ),
          SwitchListTile(
            title: const Text('Alertes de sécurité'),
            value: _alertes,
            onChanged: (v) => setState(() => _alertes = v),
            dense: true,
          ),
          SwitchListTile(
            title: const Text('Promotions'),
            value: _promotions,
            onChanged: (v) => setState(() => _promotions = v),
            dense: true,
          ),
          SwitchListTile(
            title: const Text('Mises à jour système'),
            value: _systeme,
            onChanged: (v) => setState(() => _systeme = v),
            dense: true,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}