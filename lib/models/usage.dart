import 'package:shared_preferences/shared_preferences.dart';

const String DATE_KEY = "timestamp";
const String COUNTER_KEY = "daily_refresh";

String getTodayAsString() {
  DateTime today = DateTime.now();
  String res = "${today.day}-${today.month}-${today.year}";
  return res;
}

class UsageStats {
  String? date;
  int? refreshCount;

  UsageStats getUsage(SharedPreferences prefs) {
    UsageStats dailyUsage = UsageStats();
    dailyUsage.date = prefs.getString(DATE_KEY) ?? getTodayAsString();
    dailyUsage.refreshCount = prefs.getInt(COUNTER_KEY) ?? 2;
    return dailyUsage;
  }

  Future<UsageStats> setUsage(
      SharedPreferences prefs, String? today, int? newCount) async {
    if (today != null) {
      await prefs.setString(DATE_KEY, today);
    }
    if (newCount != null) {
      await prefs.setInt(COUNTER_KEY, newCount);
    }
    return getUsage(prefs);
  }
}
