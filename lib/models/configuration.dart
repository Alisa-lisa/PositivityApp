import 'package:shared_preferences/shared_preferences.dart';

// Class properties and respective keys in SharedPreference
const String AREA_BLIST = "areas";
const String DIFF_BLIST = "difficulties";
const String ENDPOINTS = "endpoints";
const String MIN_ANSWERS = "answers";
const String PAUSE = "paused";
const String TIME_FRAME = "twindow";
const String REMINDERS = "reminders";

class UserPreference {
  List<String> areaBlacklist = []; // TBD
  List<String> difficultyBlacklist = []; //TBD
  int endpointToUse = 0;
  int minimumPositive = 2;
  bool pause = false;
  String timeFrame = "None"; // TBD
  int numberReminders = 3;

  UserPreference getPreference(SharedPreferences prefs) {
    UserPreference res = UserPreference();
    res.areaBlacklist = prefs.getStringList(AREA_BLIST) ?? res.areaBlacklist;
    res.difficultyBlacklist =
        prefs.getStringList(DIFF_BLIST) ?? res.difficultyBlacklist;
    res.endpointToUse = prefs.getInt(ENDPOINTS) ?? res.endpointToUse;
    res.minimumPositive = prefs.getInt(MIN_ANSWERS) ?? res.minimumPositive;
    res.pause = prefs.getBool(PAUSE) ?? res.pause;
    res.numberReminders = prefs.getInt(REMINDERS) ?? res.numberReminders;

    return res;
  }

  Future<UserPreference> setPreference(SharedPreferences prefs, int? endpoints,
      int? minimunAnswers, bool? pause, int? reminders) async {
    if (endpoints != null) {
      await prefs.setInt(ENDPOINTS, endpoints);
    }
    if (minimunAnswers != null) {
      await prefs.setInt(MIN_ANSWERS, minimunAnswers);
    }
    if (pause != null) {
      await prefs.setBool(PAUSE, pause);
    }
    if (reminders != null) {
      await prefs.setInt(REMINDERS, reminders);
    }

    return getPreference(prefs);
  }
}
