import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:positivityapp/const.dart';

Map<int, String> migrationsSteps = {
  1: '''
	CREATE TABLE $stats (
		id INTEGER PRIMARY KEY,
		time TEXT UNIQUE,
    input TEXT,
    difficulty TEXT,
    area TEXT,
    count INTEGER
	);
	'''
};

class DatabaseHandler {
  int version = migrationsSteps.length;

  void _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON;");
  }

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    var db = await openDatabase(join(path, 'stats.db'),
        version: version, onConfigure: _onConfigure,
        onCreate: (Database database, int version) async {
      for (int i = 1; i <= version; i++) {
        await database.execute(migrationsSteps[i]!);
      }
    }, onUpgrade: (Database database, int oldVersion, int newVersion) async {
      for (int i = oldVersion + 1; i <= newVersion; i++) {
        await database.execute(migrationsSteps[i]!);
      }
    });
    return db;
  }
}
