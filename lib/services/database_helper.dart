import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/auth_user_model.dart';
import '../models/cotisation_model.dart';
import '../models/pension_model.dart';
import '../models/dashboard_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'waajal_elek.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  //creation de la base de donnee locale
  Future<void> _onCreate(Database db, int version) async {
    // Utilisateur
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        matricule TEXT NOT NULL,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT NOT NULL,
        grade TEXT NOT NULL,
        telephone TEXT,
        date_naissance TEXT,
        date_engagement TEXT,
        date_retraite TEXT,
        statut TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // COTISATIONS
    await db.execute('''
      CREATE TABLE cotisations (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        date_versement TEXT NOT NULL,
        montant REAL NOT NULL,
        type_cotisation TEXT NOT NULL,
        statut TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // PENSIONS
    await db.execute('''
      CREATE TABLE pensions (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        date_versement TEXT NOT NULL,
        montant REAL NOT NULL,
        type_pension TEXT NOT NULL,
        statut TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // DASHBOARD
    await db.execute('''
      CREATE TABLE dashboard_stats (
        user_id TEXT PRIMARY KEY,
        capital_retraite REAL NOT NULL,
        cotisation_mensuelle REAL NOT NULL,
        total_cotisations REAL NOT NULL,
        pension_estimee REAL NOT NULL,
        taux_remplacement REAL NOT NULL,
        projection_5ans REAL NOT NULL,
        annees_service INTEGER NOT NULL,
        age_actuel INTEGER NOT NULL,
        annees_avant_retraite INTEGER NOT NULL,
        interets_cumules REAL NOT NULL,
        taux_interet REAL NOT NULL,
        projection_10ans REAL NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // RECENT ACTIVITe
    await db.execute('''
      CREATE TABLE recent_activities (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        adherant_id INTEGER NOT NULL,
        date_versement TEXT NOT NULL,
        montant REAL NOT NULL,
        statut TEXT NOT NULL,
        type TEXT NOT NULL,
        type_transaction TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Sychronisation des versions
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        last_sync TEXT NOT NULL,
        data_version TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pensions (
          id INTEGER PRIMARY KEY,
          user_id TEXT NOT NULL,
          date_versement TEXT NOT NULL,
          montant REAL NOT NULL,
          type_pension TEXT NOT NULL,
          statut TEXT NOT NULL,
          created_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS recent_activities (
          id INTEGER PRIMARY KEY,
          user_id TEXT NOT NULL,
          adherant_id INTEGER NOT NULL,
          date_versement TEXT NOT NULL,
          montant REAL NOT NULL,
          statut TEXT NOT NULL,
          type TEXT NOT NULL,
          type_transaction TEXT NOT NULL,
          created_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }
  }

  //ajoute de l'utilisateur
  Future<void> saveUser(UserProfile user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'matricule': user.matricule,
        'nom': user.nom,
        'prenom': user.prenom,
        'email': user.email,
        'grade': user.grade,
        'telephone': user.telephone,
        'date_naissance': user.dateNaissance,
        'date_engagement': user.dateEngagement,
        'date_retraite': user.dateRetraite,
        'statut': user.statut,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('User sauvegardé: ${user.nomComplet}');
  }

  Future<UserProfile?> getUser(String userId) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (res.isEmpty) return null;

    final d = res.first;
    return UserProfile(
      id: d['id'] as String,
      matricule: d['matricule'] as String,
      nom: d['nom'] as String,
      prenom: d['prenom'] as String,
      email: d['email'] as String,
      grade: d['grade'] as String,
      telephone: d['telephone'] as String?,
      dateNaissance: d['date_naissance'] as String?,
      dateEngagement: d['date_engagement'] as String?,
      dateRetraite: d['date_retraite'] as String?,
      statut: d['statut'] as String,
    );
  }

  // enregistrement cotisation
  Future<void> saveCotisations(String userId, List<Cotisation> cotisations) async {
    final db = await database;
    final batch = db.batch();

    // Supprimer les anciennes
    batch.delete('cotisations', where: 'user_id = ?', whereArgs: [userId]);

    // Insérer les nouvelles
    for (final cot in cotisations) {
      batch.insert(
        'cotisations',
        {
          'id': cot.id,
          'user_id': userId,
          'date_versement': cot.dateVersement,
          'montant': cot.montant,
          'type_cotisation': cot.typeCotisation,
          'statut': cot.statut,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('${cotisations.length} cotisations sauvegardées');
  }

  Future<List<Cotisation>> getCotisations(String userId) async {
    final db = await database;
    final res = await db.query(
      'cotisations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_versement DESC',
    );

    return res.map((d) => Cotisation(
      id: d['id'] as int,
      adherantId: int.parse(userId.split('-').last),
      dateVersement: d['date_versement'] as String,
      montant: d['montant'] as double,
      typeCotisation: d['type_cotisation'] as String,
      statut: d['statut'] as String,
    )).toList();
  }

  // enregistrement pension
  Future<void> savePensions(String userId, List<PensionModel> pensions) async {
    final db = await database;
    final batch = db.batch();

    // Supprimer les anciennes
    batch.delete('pensions', where: 'user_id = ?', whereArgs: [userId]);

    // Insérer les nouvelles
    for (final pension in pensions) {
      batch.insert(
        'pensions',
        {
          'id': pension.id,
          'user_id': userId,
          'date_versement': pension.dateVersement,
          'montant': pension.montant,
          'type_pension': pension.typePension,
          'statut': pension.statut,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('${pensions.length} pensions sauvegardées');
  }

  Future<List<PensionModel>> getPensions(String userId) async {
    final db = await database;
    final res = await db.query(
      'pensions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_versement DESC',
    );

    return res.map((d) => PensionModel(
      id: d['id'] as int,
      adherantId: int.parse(userId.split('-').last),
      dateVersement: d['date_versement'] as String,
      montant: d['montant'] as double,
      typePension: d['type_pension'] as String,
      statut: d['statut'] as String,
    )).toList();
  }

  // enregistrement tAbleau de bord
  Future<void> saveDashboardStats(String userId, DashboardStatsModel s) async {
    final db = await database;
    await db.insert(
      'dashboard_stats',
      {
        'user_id': userId,
        'capital_retraite': s.capitalRetraite,
        'cotisation_mensuelle': s.cotisationMensuelle,
        'total_cotisations': s.totalCotisations,
        'pension_estimee': s.pensionEstimee,
        'taux_remplacement': s.tauxRemplacement,
        'projection_5ans': s.projection5ans,
        'annees_service': s.anneesService,
        'age_actuel': s.ageActuel,
        'annees_avant_retraite': s.anneesAvantRetraite,
        'interets_cumules': s.interetsCumules,
        'taux_interet': s.tauxInteret,
        'projection_10ans': s.projection10ans,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Dashboard  sauvegardées');
  }

  Future<DashboardStatsModel?> getDashboardStats(String userId) async {
    final db = await database;
    final res = await db.query(
      'dashboard_stats',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (res.isEmpty) return null;

    final d = res.first;
    return DashboardStatsModel(
      capitalRetraite: d['capital_retraite'] as double,
      cotisationMensuelle: d['cotisation_mensuelle'] as double,
      totalCotisations: d['total_cotisations'] as double,
      pensionEstimee: d['pension_estimee'] as double,
      tauxRemplacement: d['taux_remplacement'] as double,
      projection5ans: d['projection_5ans'] as double,
      anneesService: d['annees_service'] as int,
      ageActuel: d['age_actuel'] as int,
      anneesAvantRetraite: d['annees_avant_retraite'] as int,
      interetsCumules: d['interets_cumules'] as double,
      tauxInteret: d['taux_interet'] as double,
      projection10ans: d['projection_10ans'] as double,
    );
  }

  // enregistrement des activites recentes
  Future<void> saveRecentActivities(String userId, List<RecentActivityModel> activities) async {
    final db = await database;
    final batch = db.batch();

    // Supprimer les anciennes
    batch.delete('recent_activities', where: 'user_id = ?', whereArgs: [userId]);

    // Insérer les nouvelles
    for (final activity in activities) {
      batch.insert(
        'recent_activities',
        {
          'id': activity.id,
          'user_id': userId,
          'adherant_id': activity.adherantId,
          'date_versement': activity.dateVersement,
          'montant': activity.montant,
          'statut': activity.statut,
          'type': activity.type,
          'type_transaction': activity.typeTransaction,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('${activities.length} activités récentes sauvegardées');
  }

  Future<List<RecentActivityModel>> getRecentActivities(String userId) async {
    final db = await database;
    final res = await db.query(
      'recent_activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_versement DESC',
      limit: 10,
    );

    return res.map((d) => RecentActivityModel(
      id: d['id'] as int,
      adherantId: d['adherant_id'] as int,
      dateVersement: d['date_versement'] as String,
      montant: d['montant'] as double,
      statut: d['statut'] as String,
      type: d['type'] as String,
      typeTransaction: d['type_transaction'] as String,
    )).toList();
  }

  // Synchronisation
  Future<void> updateSyncMetadata(String key, DateTime time) async {
    final db = await database;
    await db.insert(
      'sync_metadata',
      {
        'key': key,
        'last_sync': time.toIso8601String(),
        'data_version': '1.0',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DateTime?> getLastSync(String key) async {
    final db = await database;
    final res = await db.query('sync_metadata', where: 'key = ?', whereArgs: [key]);
    if (res.isEmpty) return null;
    return DateTime.parse(res.first['last_sync'] as String);
  }

  // Suppression des anciennes donnes de l'utilisateur
  Future<void> clearUserData(String userId) async {
    final db = await database;
    await db.delete('cotisations', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('pensions', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('dashboard_stats', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('recent_activities', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
    print('Données locales supprimées pour: $userId');
  }
}