import 'package:shared_preferences/shared_preferences.dart';

const String dateKey = "todays_sessions";
const String counterKey = "daily_refresh";

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
    dailyUsage.date = prefs.getString(dateKey) ?? getTodayAsString();
    dailyUsage.refreshCount = prefs.getInt(counterKey) ?? 2;
    return dailyUsage;
  }

  Future<UsageStats> setUsage(
      SharedPreferences prefs, String? today, int? newCount) async {
    if (today != null) {
      await prefs.setString(dateKey, today);
    }
    if (newCount != null) {
      await prefs.setInt(counterKey, newCount);
    }
    return getUsage(prefs);
  }
}
