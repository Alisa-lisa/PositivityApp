import 'package:shared_preferences/shared_preferences.dart';

const String DATE_KEY = "timestamp";
const String COUNTER_KEY = "daily_refresh";

class UsageStats {
  String date = DateTime.now().toString();
  int refreshCount = 2;

  UsageStats getUsage(SharedPreferences prefs) {
    UsageStats dailyUsage = UsageStats();
    dailyUsage.date = prefs.getString(DATE_KEY) ?? dailyUsage.date;
    dailyUsage.refreshCount =
        prefs.getInt(COUNTER_KEY) ?? dailyUsage.refreshCount;
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
