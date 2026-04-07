import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waajal_elek/pages/parametre_page.dart';
import 'package:waajal_elek/pages/pensions_page.dart';
import 'package:waajal_elek/pages/profile_page.dart';
import 'package:waajal_elek/pages/similation_page.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'cotisation_page.dart';
import 'dashboard_page.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  //int _notificationCount = 5;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CotisationsScreen(),
    //DocumentsScreen(),
    PensionsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    //  FIX : Synchroniser UserProvider dès l'ouverture de HomeScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUserProvider();
    });
  }

  // Alimente UserProvider depuis AuthProvider si ce n'est pas déjà fait
  void _syncUserProvider() {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (userProvider.userProfile == null && authProvider.userProfile != null) {
      userProvider.setUserProfile(authProvider.userProfile);
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(
            icon,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[700],
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black87,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onTap,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waajal Ëlëk'),
        actions: [
          //Stack(
           // children: [
             // IconButton(
             //   icon: const Icon(Icons.notifications_outlined),
             //   onPressed: () {
                  // Action pour voir les notifications
              //  },
             // ),
              //if (_notificationCount > 0)
              //  Positioned(
              //    right: 6,
              //    top: 6,
                //  child: Container(
                 //   padding: const EdgeInsets.all(2),
                 //   decoration: BoxDecoration(
                  //    color: Colors.red,
                  //    borderRadius: BorderRadius.circular(8),
                  //  ),
                  //  constraints: const BoxConstraints(
                   //   minWidth: 16,
                    //  minHeight: 16,
                  //  ),
                  //  child: Text(
                   //   '$_notificationCount',
                  //    style: const TextStyle(
                   //     color: Colors.white,
                    //    fontSize: 10,
                    //    fontWeight: FontWeight.bold,
                    //  ),
                    //  textAlign: TextAlign.center,
                   // ),
                //  ),
             //   ),
          //  ],
          //),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //Icône
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.support_agent,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 15),

                        //Titre
                        const Text(
                          "Besoin d’aide ?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        //Contenu
                        const Text(
                          "Bienvenue sur Waajal Elek.\n\n"
                              "Utilisez le menu pour accéder à vos cotisations, pensions et profil.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 20),

                        //Bouton
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Compris"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // 🔵 HEADER MODERNE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.prenom.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.nomComplet ?? 'Chargement...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // 📋 MENU
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: "Tableau de bord",
                    selected: _currentIndex == 0,
                    onTap: () {
                      setState(() => _currentIndex = 0);
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet,
                    title: "Cotisations",
                    selected: _currentIndex == 1,
                    onTap: () {
                      setState(() => _currentIndex = 1);
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.payments,
                    title: "Pensions",
                    selected: _currentIndex == 2,
                    onTap: () {
                      setState(() => _currentIndex = 2);
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.calculate,
                    title: "Simulations",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SimulationScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 30),

                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: "Paramètres",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 🔴 LOGOUT
            Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final authProvider = context.read<AuthProvider>();
                    await authProvider.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Déconnexion"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Cotisations',
          ),
          //BottomNavigationBarItem(
           // icon: Icon(Icons.account_balance_wallet),
           // label: 'Document',
          //),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Pensions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
