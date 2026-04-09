import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/app_status_service.dart';
import 'home_page.dart';
import 'authentification/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Un seul point d'entrée — _initialize gère tout
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final authProvider = context.read<AuthProvider>();

    await authProvider.restoreSession();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final appStatus = await AppStatusService.getAppStatus();

      if (!mounted) return;

      if (!appStatus.isActive) {
        _showMaintenanceDialog(appStatus.message ?? "L'application est temporairement indisponible.");
        return;
      }

      if (appStatus.needsUpdate) {
        _showUpdateDialog(appStatus.message ?? "Une nouvelle version est disponible.");
        return;
      }

      // ✅ Session locale valide → on va à Home
      // Si le token est invalide/expiré, le 401 sur le prochain appel
      // déclenchera automatiquement forceLogout() → redirection login
      if (!authProvider.isAuthenticated) {
        _goToLogin();
        return;
      }

      final userProvider = context.read<UserProvider>();
      final userId = authProvider.userId?.toString();
      if (userId != null) {
        await userProvider.fetchUserProfile(userId);
      }

      if (!mounted) return;
      _goToHome();

    } catch (e) {
      debugPrint('Erreur splash: $e');
      if (!mounted) return;
      if (authProvider.isAuthenticated) {
        _goToHome();
      } else {
        _goToLogin();
      }
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  //Dialog de maintenance

  void _showMaintenanceDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.9, //80% de écran
          child: _AppDialog(
            icon: Icons.build_circle_outlined,
            iconColor: Colors.orange.shade700,
            iconBackground: Colors.orange.shade50,
            title: 'Maintenance en cours',
            message: message,
            actions: [
              _AppDialogButton(
                label: 'Réessayer',
                icon: Icons.refresh,
                color: Colors.orange.shade700,
                onPressed: () {
                  Navigator.of(context).pop();
                  _initialize();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AppDialog(
        icon: Icons.system_update_alt,
        iconColor: Colors.blue.shade700,
        iconBackground: Colors.blue.shade50,
        title: 'Mise à jour disponible',
        message: message,
        actions: [
          _AppDialogButton(
            label: 'Mettre à jour',
            icon: Icons.download,
            color: Colors.blue.shade700,
            onPressed: () async {
              final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.diamonotech.we');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAccessDeniedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AppDialog(
        icon: Icons.lock_outline,
        iconColor: Colors.red.shade700,
        iconBackground: Colors.red.shade50,
        title: 'Accès refusé',
        message: message,
        actions: [
          _AppDialogButton(
            label: 'Se déconnecter',
            icon: Icons.logout,
            color: Colors.red.shade700,
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (mounted) Navigator.of(context).pop();
              _goToLogin();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/wadjal elek.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'Waajal Ëlëk',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Système Endogène de Retraite par Capitalisation des Armées (SERCA)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

//WIDGETS RÉUTILISABLES

class _AppDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final List<_AppDialogButton> actions;

  const _AppDialog({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 48),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            height: 1.5,
            fontSize: 14,
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: actions
          .map((btn) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: btn.onPressed,
          icon: Icon(btn.icon),
          label: Text(btn.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: btn.color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ))
          .toList(),
    );
  }
}

class _AppDialogButton {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _AppDialogButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}