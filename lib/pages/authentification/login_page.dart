import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/account_suggestion_service.dart';
import 'first_login_page.dart';
import '../home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _passwordAutoFilled = false;

  List<String> _savedAccounts = [];

  // Liste filtrée affichée dans le dropdown
  List<String> _filteredAccounts = [];
  bool _showDropdown = false;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadSavedAccounts();

    _usernameFocusNode.addListener(() {
      if (_usernameFocusNode.hasFocus) {
        _updateDropdown(_usernameController.text);
      } else {
        _hideDropdown();
      }
    });

    _usernameController.addListener(() {
      if (_usernameFocusNode.hasFocus) {
        _updateDropdown(_usernameController.text);
      }
    });
  }

  @override
  void dispose() {
    _hideDropdown();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  // ─── Comptes sauvegardés ──────────────────────────────────────────────────

  Future<void> _loadSavedAccounts() async {
    final accounts = await AccountSuggestionService.getAccounts();
    setState(() => _savedAccounts = accounts);
  }

  // ─── Dropdown overlay ─────────────────────────────────────────────────────

  void _updateDropdown(String query) {
    final filtered = query.isEmpty
        ? List<String>.from(_savedAccounts)
        : _savedAccounts
        .where((a) => a.toLowerCase().contains(query.toLowerCase()))
        .toList();

    _filteredAccounts = filtered;

    if (filtered.isEmpty) {
      _hideDropdown();
      return;
    }

    if (_overlayEntry != null) {
      // Mettre à jour l'overlay existant
      _overlayEntry!.markNeedsBuild();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 48, // padding 24 de chaque côté
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // hauteur du champ
          child: _buildDropdownList(),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildDropdownList() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: StatefulBuilder(
            builder: (context, setStateInner) {
              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredAccounts.length,
                itemBuilder: (context, index) {
                  final account = _filteredAccounts[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.account_circle_outlined),
                    title: Text(account),
                    trailing: GestureDetector(
                      onTap: () async {
                        await _removeAccount(account);
                        setStateInner(() {});
                      },
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.grey),
                    ),
                    onTap: () {
                      _hideDropdown();
                      _onAccountSelected(account);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Sélection d'un compte ────────────────────────────────────────────────

  Future<void> _onAccountSelected(String username) async {
    _usernameController.text = username;
    _usernameController.selection = TextSelection.fromPosition(
      TextPosition(offset: username.length),
    );

    final savedPassword = await AccountSuggestionService.getPassword(username);

    setState(() {
      if (savedPassword != null && savedPassword.isNotEmpty) {
        _passwordController.text = savedPassword;
        _passwordAutoFilled = true;
        _rememberMe = true;
      } else {
        _passwordController.clear();
        _passwordAutoFilled = false;
      }
    });

    // Déplacer le focus vers le mot de passe
    FocusScope.of(context).nextFocus();
  }

  // ─── Suppression d'un compte ──────────────────────────────────────────────

  Future<void> _removeAccount(String username) async {
    await AccountSuggestionService.removeAccount(username);
    await _loadSavedAccounts();

    _filteredAccounts.remove(username);

    if (_usernameController.text == username) {
      _usernameController.clear();
      _passwordController.clear();
      setState(() => _passwordAutoFilled = false);
    }

    if (_filteredAccounts.isEmpty) {
      _hideDropdown();
    } else {
      _overlayEntry?.markNeedsBuild();
    }
  }

  // ─── Connexion ────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signIn(
      username,
      password,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (success) {
      await AccountSuggestionService.saveAccount(username);

      if (_rememberMe) {
        await AccountSuggestionService.savePassword(username, password);
      } else {
        await AccountSuggestionService.clearPassword(username);
      }

      final userProvider = context.read<UserProvider>();
      userProvider.setUserProfile(authProvider.userProfile);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur de connexion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 30),

                // ── Logo
                Center(
                  child: Image.asset(
                    'assets/images/wadjal elek.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Waajal Ëlëk',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous à votre compte',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // ── Champ matricule avec dropdown custom
                CompositedTransformTarget(
                  link: _layerLink,
                  child: TextFormField(
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Matricule',
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: 'Ex: SN-24-08751',
                      // Flèche bas pour indiquer qu'il y a des suggestions
                      suffixIcon: _savedAccounts.isNotEmpty
                          ? Icon(Icons.arrow_drop_down,
                          color: Colors.grey.shade400)
                          : null,
                    ),
                    onChanged: (_) {
                      if (_passwordAutoFilled) {
                        setState(() {
                          _passwordController.clear();
                          _passwordAutoFilled = false;
                        });
                      }
                    },
                    onTap: () {
                      // Ouvrir le dropdown au tap même si champ vide
                      _updateDropdown(_usernameController.text);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre matricule';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ── Champ mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_passwordAutoFilled)
                          Tooltip(
                            message: 'Mot de passe mémorisé',
                            child: Icon(Icons.key,
                                size: 18, color: Colors.green.shade600),
                          ),
                        IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                        ),
                      ],
                    ),
                  ),
                  onChanged: (_) {
                    if (_passwordAutoFilled) {
                      setState(() => _passwordAutoFilled = false);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // ── Se souvenir de moi
                CheckboxListTile(
                  value: _rememberMe,
                  onChanged: (value) =>
                      setState(() => _rememberMe = value ?? true),
                  title: const Text('Se souvenir de moi'),
                  subtitle: const Text(
                    'Mémorise votre matricule et mot de passe',
                    style: TextStyle(fontSize: 11),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                // ── Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FirstLoginPage()),
                    ),
                    child: const Text('Ré(initialiser) le mot de passe'),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Bouton connexion
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed:
                      authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                          : const Text('Se connecter'),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Connexion sécurisée',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}