import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  DB._();

  static final DB instance = DB._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    return await _initDatabase();
  }

  static recreate() async {
    await deleteDatabase(join(await getDatabasesPath(), 'gymbro.db'));
    print('criado base de novo');
  }

  _initDatabase() async {
    // _recreate();
    return await openDatabase(
      join(await getDatabasesPath(), 'gymbro.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(Database db, int versao) async {
    await db.execute(_userPrefsTable);
    await db.insert(TableNames.userPrefs, {
      'uId': 'null',
      'theme': 2,
      'lastLogin': DateTime.now().toIso8601String(),
    });
    await db.execute(_workoutsTable);
    await db.execute(_toBeUploaded);
  }

  String get _userPrefsTable => '''
    CREATE TABLE ${TableNames.userPrefs} (
      uid TEXT PRIMARY KEY,
      theme INTEGER,
      lastLogin DATETIME NOT NULL
    );
  ''';

  String get _workoutsTable => '''
    CREATE TABLE ${TableNames.workouts} (
      id INTEGER NOT NULL,
      uId TEXT NOT NULL,
      isActive BOOLEAN NOT NULL,
      sortOrder INTEGER NOT NULL,
      name TEXT NOT NULL,
      creation DATETIME NOT NULL,
      PRIMARY KEY (id, uId)
    );
  ''';

  String get _toBeUploaded => '''
    CREATE TABLE ${TableNames.toBeUploaded} (
      origin TEXT NOT NULL,
      id INTEGER NOT NULL,
      uid TEXT NOT NULL,
      extra INTEGER,
      PRIMARY KEY (origin, id, uid)
    );
  ''';
}
