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

  _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'gymbro.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(Database db, int versao) async {
    await db.execute(_userPrefs);
    await db.insert('user_prefs', {'uid': 'null', 'theme': 2});
  }

  String get _userPrefs => '''
    CREATE TABLE user_prefs (
      uid TEXT PRIMARY KEY,
      theme INTEGER
    );
''';

  String get _workoutsTable => '''
    CREATE TABLE workouts (
      id INT PRIMARY KEY AUTOINCREMENT,
      uid TEXT
    ) WITHOUT ROWID;
''';
}
