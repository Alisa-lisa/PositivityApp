import 'package:shared_preferences/shared_preferences.dart';

// Class properties and respective keys in SharedPreference
const String areaBlistKey = "areas";
const String difBlistKey = "difficulties";
const String endpointsKey = "endpoints";
const String minAnswersKey = "answers";
const String pauseKey = "paused";
const String timeFrameKey = "twindow";
const String remindersKey = "reminders";

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
    res.areaBlacklist = prefs.getStringList(areaBlistKey) ?? res.areaBlacklist;
    res.difficultyBlacklist =
        prefs.getStringList(difBlistKey) ?? res.difficultyBlacklist;
    res.endpointToUse = prefs.getInt(endpointsKey) ?? res.endpointToUse;
    res.minimumPositive = prefs.getInt(minAnswersKey) ?? res.minimumPositive;
    res.pause = prefs.getBool(pauseKey) ?? res.pause;
    res.numberReminders = prefs.getInt(remindersKey) ?? res.numberReminders;

    return res;
  }

  Future<UserPreference> setPreference(SharedPreferences prefs, int? endpoints,
      int? minimunAnswers, bool? pause, int? reminders) async {
    if (endpoints != null) {
      await prefs.setInt(endpointsKey, endpoints);
    }
    if (minimunAnswers != null) {
      await prefs.setInt(minAnswersKey, minimunAnswers);
    }
    if (pause != null) {
      await prefs.setBool(pauseKey, pause);
    }
    if (reminders != null) {
      await prefs.setInt(remindersKey, reminders);
    }

    return getPreference(prefs);
  }
}
