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
    return await openDatabase(
      join(await getDatabasesPath(), 'gymbro.db'),
      version: 3,
      onCreate: _onCreate,
      // onUpgrade: _testeUpgrade,
    );
  }

  // _testeUpgrade(Database db, int oldVersion, int newVersion) {
  //   print('new version $newVersion');
  //   print('old version $oldVersion');
  //   try {
  //     db.execute("ALTER TABLE ${TableNames.exercises} ADD COLUMN namept TEXT");
  //   } catch (e) {
  //     print("Altering ${TableNames.exercises}: ${e.toString()}");
  //   }
  // }

  _onCreate(Database db, int versao) async {
    await db.execute(_userPrefsTable);
    await db.insert(TableNames.userPrefs, {
      'uid': 'null',
      'theme': 2,
    });
    await db.execute(_routinesTable);
    await db.execute(_workoutsTable);
    await db.execute(_exercisesTable);
    await db.execute(_toBeUploaded);
  }

  String get _userPrefsTable => '''
    CREATE TABLE ${TableNames.userPrefs} (
      uid TEXT PRIMARY KEY,
      theme INTEGER,
      lastlogin DATETIME
    );
  ''';

  String get _routinesTable => '''
    CREATE TABLE routines (
      id INTEGER NOT NULL,
      uid TEXT NOT NULL,
      name TEXT NOT NULL,
      isactive BOOLEAN NOT NULL,
      sortorder INTEGER NOT NULL,
      description TEXT NULL,
      creationdate DATETIME NOT NULL,
      PRIMARY KEY (id, uid)
    );
  ''';

  String get _workoutsTable => '''
    CREATE TABLE ${TableNames.workouts} (
      id INTEGER NOT NULL,
      uid TEXT NOT NULL,
      routineid INTEGER NOT NULL,
      sortorder INTEGER NOT NULL,
      name TEXT NOT NULL,
      creationdate DATETIME NOT NULL,
      PRIMARY KEY (id, uId)
    );
  ''';

  String get _exercisesTable => '''
    CREATE TABLE ${TableNames.exercises} (
      id INTEGER NOT NULL,
      name TEXT NOT NULL,
      system BOOLEAN NOT NULL,
      category TEXT NOT NULL,
      primarymuscles TEXT NOT NULL,
      secondarymuscles TEXT,
      level TEXT,
      videourl TEXT,
      imageurl TEXT,
      equipment TEXT,
      possiblenames TEXT,
      PRIMARY KEY (id)
    );
  ''';

  String get _toBeUploaded => '''
    CREATE TABLE ${TableNames.toBeUploaded} (
      origin TEXT NOT NULL,
      operation TEXT NOT NULL,
      id INTEGER NOT NULL,
      uid TEXT NOT NULL,
      extra INTEGER NOT NULL,
      UNIQUE(origin, operation, id, uid, extra)
    );
  ''';
}
