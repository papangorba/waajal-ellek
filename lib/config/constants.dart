class AppConstants {
  static const String appName = 'Waajal Ëlëk';
  static const String appVersion = '1.0.0';

  static const int defaultPageSize = 20;
  static const int maxRetries = 3;
  static const Duration cacheExpiration = Duration(hours: 24);

  static const Map<String, String> militaryRanks = {
    'soldat': 'Soldat',
    'caporal': 'Caporal',
    'sergent': 'Sergent',
    'adjudant': 'Adjudant',
    'lieutenant': 'Lieutenant',
    'capitaine': 'Capitaine',
    'commandant': 'Commandant',
    'colonel': 'Colonel',
    'general': 'Général',
  };

  static const Map<String, String> pensionTypes = {
    'rente': 'Rente',
    'capital': 'Capital',
    'mixte': 'Mixte',
  };

  static const Map<String, String> memberStatus = {
    'actif': 'Actif',
    'retraite': 'Retraité',
    'suspendu': 'Suspendu',
    'demissionnaire': 'Démissionnaire',
  };
}

class ApiEndpoints {
  static const String profile = '/profile';
  static const String cotisations = '/cotisations';
  static const String pensions = '/pensions';
  static const String simulations = '/simulations';
  static const String documents = '/documents';
  static const String notifications = '/notifications';
}

class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String cotisations = '/cotisations';
  static const String pensions = '/pensions';
  static const String simulations = '/simulations';
  static const String profile = '/profile';
  static const String documents = '/documents';
  static const String help = '/help';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastSyncDate = 'last_sync_date';
}
