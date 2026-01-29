import 'package:shared_preferences/shared_preferences.dart';

class AccountSuggestionService {
  static const _key = 'saved_accounts';

  static Future<List<String>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> saveAccount(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_key) ?? [];

    if (!accounts.contains(email)) {
      accounts.add(email);
      await prefs.setStringList(_key, accounts);
    }
  }

  static Future<void> removeAccount(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_key) ?? [];

    accounts.remove(email);
    await prefs.setStringList(_key, accounts);
  }
}
