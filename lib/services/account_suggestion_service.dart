import 'package:shared_preferences/shared_preferences.dart';

class AccountSuggestionService {
  static const _keyAccounts = 'saved_accounts';
  static const _keyPasswordPrefix = 'saved_password_';

  // ─── Comptes ──────────────────────────────────────────────────────────────

  static Future<List<String>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyAccounts) ?? [];
  }

  static Future<void> saveAccount(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_keyAccounts) ?? [];

    if (!accounts.contains(username)) {
      accounts.add(username);
      await prefs.setStringList(_keyAccounts, accounts);
    }
  }

  static Future<void> removeAccount(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_keyAccounts) ?? [];

    accounts.remove(username);
    await prefs.setStringList(_keyAccounts, accounts);

    // Supprimer aussi le mot de passe associé
    await prefs.remove('$_keyPasswordPrefix$username');
  }

  // ─── Mots de passe associés ───────────────────────────────────────────────

  /// Sauvegarde le mot de passe uniquement si rememberMe est coché
  static Future<void> savePassword(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPasswordPrefix$username', password);
  }

  /// Retourne le mot de passe sauvegardé pour un compte, ou null
  static Future<String?> getPassword(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPasswordPrefix$username');
  }

  /// Supprime uniquement le mot de passe (garde le compte dans la liste)
  static Future<void> clearPassword(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPasswordPrefix$username');
  }
}