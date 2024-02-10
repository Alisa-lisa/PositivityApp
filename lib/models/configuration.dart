import 'package:shared_preferences/shared_preferences.dart';

class UserPreference {
  List<String> areaBlacklist = [];
  List<String> difficultyBlacklist = [];
  int endpointToUse = 0;
  int minimumPositive = 2;
  bool pause = false;
  String timeFrame = "None";
  int numberReminders = 3;

  late SharedPreferences _prefs;

  UserPreference() {
    _initPreference();
  }

  Future<void> _initPreference() async {
    _prefs = await SharedPreferences.getInstance();
  }

  UserPreference getPreference() {
    UserPreference res = UserPreference();
    res.areaBlacklist = _prefs.getStringList("areas") ?? res.areaBlacklist;
    res.difficultyBlacklist =
        _prefs.getStringList("difficulties") ?? res.difficultyBlacklist;
    res.endpointToUse = _prefs.getInt("endpoints") ?? res.endpointToUse;
    res.minimumPositive =
        _prefs.getInt("minimum_answers") ?? res.minimumPositive;
    res.pause = _prefs.getBool("paused") ?? res.pause;
    res.numberReminders = _prefs.getInt("reminders") ?? res.numberReminders;

    return res;
  }

  void setPrefernce() {}
}
