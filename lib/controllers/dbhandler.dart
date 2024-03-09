import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Map<int, String> migrationsSteps = {
  1: '''
	CREATE TABLE Stats (
		id INTEGER PRIMARY KEY NOT NULL,
		time TEXT NOT NULL UNIQUE,
    input TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    area TEXT NOT NULL
	);
	'''
};

class DatabaseHandler {
  int version = migrationsSteps.length;

  _onConfigure(Database db) async {
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
