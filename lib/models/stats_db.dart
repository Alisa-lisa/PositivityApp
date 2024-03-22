import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:positivityapp/const.dart';

class Stats {
  int? id;
  String time;
  String input;
  String difficulty;
  String area;
  int count;

  Stats(
      {this.id,
      required this.time,
      required this.input,
      required this.difficulty,
      required this.area,
      required this.count});

  Stats.fromMap(Map<String, dynamic> obj)
      : id = obj['id'],
        time = obj['time'],
        input = obj['input'],
        difficulty = obj['difficulty'],
        area = obj['area'],
        count = obj['count'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'time': time,
      'input': input,
      'difficulty': difficulty,
      'area': area,
      'count': count
    };
  }

  List<String> prepareCsv() {
    return <String>[
      id.toString(),
      time,
      input,
      difficulty,
      area,
      count.toString()
    ];
  }

  static Future<int> write(Database db, Stats newEntry) async {
    return await db.insert(stats, newEntry.toMap());
  }

  static Future<List<Stats>> filter(Database db) async {
    var res = await db.query(stats);
    return res.map((t) => Stats.fromMap(t)).toList();
  }

  static Future<String> dump(Database db, String dir) async {
    List<List<String>> data = [];
    var tags = await filter(db);
    for (var l in tags) {
      data.add(l.prepareCsv());
    }
    String csvData = const ListToCsvConverter().convert(data);
    String statsPath = "$dir/stats.csv";
    await File(statsPath).writeAsString(csvData);
    return statsPath;
  }
}
