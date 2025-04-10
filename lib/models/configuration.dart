import 'package:shared_preferences/shared_preferences.dart';

// Class properties and respective keys in SharedPreference
const String topicsKey = "topics";
const String lvlKey = "difficulty";
const String minAnswersKey = "answers";

class UserPreference {
  List<String> topics = [];
  List<String> difficulty = [];
  int minAnswers = 3;

  UserPreference getPreference(SharedPreferences prefs) {
    UserPreference res = UserPreference();
    res.topics = prefs.getStringList(topicsKey) ?? res.topics;
    res.difficulty = prefs.getStringList(lvlKey) ?? res.difficulty;
    res.minAnswers = prefs.getInt(minAnswersKey) ?? res.minAnswers;
    return res;
  }

  Future<UserPreference> setPreference(
      SharedPreferences prefs, List<String> topics, List<String> lvl) async {
    if (topics.isNotEmpty) {
      await prefs.setStringList(topicsKey, topics);
    }
    if (lvl.isNotEmpty) {
      await prefs.setStringList(lvlKey, lvl);
    }
    // if (minimunAnswers != null) {
    //   await prefs.setInt(minAnswersKey, minimunAnswers);
    // }

    return getPreference(prefs);
  }
}
