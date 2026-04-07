import 'dart:convert';
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
      version: 7,              // ← incrémenté
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    // Table users
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

    // Table cotisations
    await db.execute('''
      CREATE TABLE cotisations (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        adherant_id INTEGER NOT NULL,
        date_versement TEXT,
        montant REAL NOT NULL,
        type_cotisation TEXT NOT NULL,
        statut TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table pensions
    await db.execute('''
      CREATE TABLE pensions (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        adherant_id INTEGER NOT NULL,
        date_versement TEXT,
        montant REAL NOT NULL,
        type_pension TEXT NOT NULL,
        statut TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table dashboard — stockage JSON brut, indépendant des clés
    await db.execute('''
      CREATE TABLE dashboard_stats (
        user_id TEXT PRIMARY KEY,
        panels_json TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table activités récentes
    await db.execute('''
      CREATE TABLE recent_activities (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        adherant_id INTEGER NOT NULL,
        date_versement TEXT,
        montant REAL NOT NULL,
        statut TEXT NOT NULL,
        type TEXT NOT NULL,
        type_transaction TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table sync
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        last_sync TEXT NOT NULL,
        data_version TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      await db.execute('DROP TABLE IF EXISTS cotisations');
      await db.execute('''
        CREATE TABLE cotisations (
          id INTEGER PRIMARY KEY,
          user_id TEXT NOT NULL,
          adherant_id INTEGER NOT NULL,
          date_versement TEXT,
          montant REAL NOT NULL,
          type_cotisation TEXT NOT NULL,
          statut TEXT,
          created_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      await db.execute('DROP TABLE IF EXISTS pensions');
      await db.execute('''
        CREATE TABLE pensions (
          id INTEGER PRIMARY KEY,
          user_id TEXT NOT NULL,
          adherant_id INTEGER NOT NULL,
          date_versement TEXT,
          montant REAL NOT NULL,
          type_pension TEXT NOT NULL,
          statut TEXT,
          created_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      await db.execute('DROP TABLE IF EXISTS recent_activities');
      await db.execute('''
        CREATE TABLE recent_activities (
          id INTEGER PRIMARY KEY,
          user_id TEXT NOT NULL,
          adherant_id INTEGER NOT NULL,
          date_versement TEXT,
          montant REAL NOT NULL,
          statut TEXT NOT NULL,
          type TEXT NOT NULL,
          type_transaction TEXT NOT NULL,
          created_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }

    // ← Migration vers version 7 : dashboard générique JSON
    if (oldVersion < 7) {
      await db.execute('DROP TABLE IF EXISTS dashboard_stats');
      await db.execute('''
        CREATE TABLE dashboard_stats (
          user_id TEXT PRIMARY KEY,
          panels_json TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }
  }

  // ─── USERS ───────────────────────────────────────────────────────────────

  Future<void> saveUser(UserProfile user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': user.userId?.toString(),
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
      userId: int.parse(d['id'] as String),
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

  // ─── COTISATIONS ─────────────────────────────────────────────────────────

  Future<void> saveCotisations(
      String userId, int adherantId, List<Cotisation> cotisations) async {
    final db = await database;
    final batch = db.batch();

    batch.delete('cotisations', where: 'user_id = ?', whereArgs: [userId]);

    for (final cot in cotisations) {
      batch.insert(
        'cotisations',
        {
          'id': cot.id,
          'user_id': userId,
          'adherant_id': adherantId,
          'date_versement': cot.dateVersement ?? '',
          'montant': cot.montant,
          'type_cotisation': cot.typeCotisation,
          'statut': cot.statut ?? '',
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

    return res.map((d) {
      final dateVersement = d['date_versement'] as String?;
      return Cotisation(
        id: d['id'] as int,
        adherantId: d['adherant_id'] as int,
        dateVersement: (dateVersement == null || dateVersement.isEmpty)
            ? null
            : dateVersement,
        montant: d['montant'] as double,
        typeCotisation: d['type_cotisation'] as String,
        statut: d['statut'] as String?,
      );
    }).toList();
  }

  // ─── PENSIONS ─────────────────────────────────────────────────────────────

  Future<void> savePensions(
      String userId, int adherantId, List<PensionModel> pensions) async {
    final db = await database;
    final batch = db.batch();

    batch.delete('pensions', where: 'user_id = ?', whereArgs: [userId]);

    for (final pension in pensions) {
      batch.insert(
        'pensions',
        {
          'id': pension.id,
          'user_id': userId,
          'adherant_id': adherantId,
          'date_versement': pension.dateVersement ?? '',
          'montant': pension.montant,
          'type_pension': pension.typePension,
          'statut': pension.statut ?? '',
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

    return res.map((d) {
      final dateVersement = d['date_versement'] as String?;
      return PensionModel(
        id: d['id'] as int,
        adherantId: d['adherant_id'] as int,
        dateVersement: (dateVersement == null || dateVersement.isEmpty)
            ? null
            : dateVersement,
        montant: d['montant'] as double,
        typePension: d['type_pension'] as String,
        statut: d['statut'] as String?,
      );
    }).toList();
  }

  // ─── DASHBOARD — JSON brut, indépendant des clés ──────────────────────────

  Future<void> saveDashboardStats(
      String userId, DashboardStatsModel stats) async {
    final db = await database;

    final panelsJson = jsonEncode(
      stats.panels.map((p) => {
        'key': p.key,
        'label': p.label,
        'value': p.value,
        'indicators': p.indicators.map((i) => {
          'key': i.key,
          'label': i.label,
          'value': i.value,
        }).toList(),
      }).toList(),
    );

    await db.insert(
      'dashboard_stats',
      {
        'user_id': userId,
        'panels_json': panelsJson,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Dashboard sauvegardé (${stats.panels.length} panels)');
  }

  Future<DashboardStatsModel?> getDashboardStats(String userId) async {
    final db = await database;
    final res = await db.query(
      'dashboard_stats',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (res.isEmpty) return null;

    final rawPanels =
    jsonDecode(res.first['panels_json'] as String) as List<dynamic>;

    return DashboardStatsModel(
      panels: rawPanels
          .map((e) => DashboardPanel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ─── ACTIVITÉS RÉCENTES ───────────────────────────────────────────────────

  Future<void> saveRecentActivities(
      String userId, List<RecentActivityModel> activities) async {
    final db = await database;
    final batch = db.batch();

    batch.delete('recent_activities', where: 'user_id = ?', whereArgs: [userId]);

    for (final activity in activities) {
      batch.insert(
        'recent_activities',
        {
          'id': activity.id,
          'user_id': userId,
          'adherant_id': activity.adherantId,
          'date_versement': activity.dateVersement ?? '',
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
      limit: 20,
    );

    return res.map((d) {
      final dateVersement = d['date_versement'] as String?;
      return RecentActivityModel(
        id: d['id'] as int,
        adherantId: d['adherant_id'] as int,
        dateVersement: (dateVersement == null || dateVersement.isEmpty)
            ? null
            : dateVersement,
        montant: d['montant'] as double,
        statut: d['statut'] as String,
        type: d['type'] as String,
        typeTransaction: d['type_transaction'] as String,
      );
    }).toList();
  }

  // ─── SYNC METADATA ────────────────────────────────────────────────────────

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
    final res =
    await db.query('sync_metadata', where: 'key = ?', whereArgs: [key]);
    if (res.isEmpty) return null;
    return DateTime.parse(res.first['last_sync'] as String).toLocal();
  }

  Future<void> updateLastSync(String key) async {
    final db = await database;
    await db.insert(
      'sync_metadata',
      {
        'key': key,
        'last_sync': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── CLEAR USER DATA ──────────────────────────────────────────────────────

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