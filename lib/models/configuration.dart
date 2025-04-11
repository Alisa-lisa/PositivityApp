import 'package:shared_preferences/shared_preferences.dart';

class UserConfiguration {
  static const String topicsKey = "topics";
  static const String lvlKey = "difficulty";
  static const String minAnswersKey = "answers";
  static const String lastUpdateKey = "lastTimestamp";
  static const String counterKey = "refreshCounter";

  // Singleton
  static UserConfiguration? _instance;
  // Fields
  List<String> topics = [];
  List<String> difficulty = [];
  int minAnswers = 3;
  String? lastUpdated;
  int refreshCount = 0;

  // SharedPreferences instance
  late SharedPreferences _prefs;
  bool _initialized = false;

  // Private constructor
  UserConfiguration._();

  // Factory constructor for singleton pattern
  static Future<UserConfiguration> getInstance() async {
    if (_instance == null) {
      _instance = UserConfiguration._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  // Initialize from SharedPreferences
  Future<void> _initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _loadFromPrefs();
      _initialized = true;
    }
  }

  // Load all values from preferences
  void _loadFromPrefs() {
    topics = _prefs.getStringList(topicsKey) ?? [];
    difficulty = _prefs.getStringList(lvlKey) ?? [];
    minAnswers = _prefs.getInt(minAnswersKey) ?? 3;
    lastUpdated = _prefs.getString(lastUpdateKey);
    refreshCount = _prefs.getInt(counterKey) ?? 0;
  }

  // Save all values to preferences
  Future<void> save() async {
    await _prefs.setStringList(topicsKey, topics);
    await _prefs.setStringList(lvlKey, difficulty);
    await _prefs.setInt(minAnswersKey, minAnswers);
    if (lastUpdated != null) {
      await _prefs.setString(lastUpdateKey, lastUpdated!);
    }
    await _prefs.setInt(counterKey, refreshCount);
  }

  // Update specific values and save
  Future<void> updatePreferences(
    List<String>? newTopics,
    List<String>? newDifficulty,
    int? newMinAnswers,
    String? newLastUpdated,
    int? newRefreshCount,
  ) async {
    if (newTopics != null) topics = newTopics;
    if (newDifficulty != null) difficulty = newDifficulty;
    if (newMinAnswers != null) minAnswers = newMinAnswers;
    if (newLastUpdated != null) lastUpdated = newLastUpdated;
    if (newRefreshCount != null) refreshCount = newRefreshCount;

    await save();
  }

  // Increment refresh counter
  Future<void> incrementRefreshCount() async {
    refreshCount++;
    await _prefs.setInt(counterKey, refreshCount);
  }

  // Update last updated timestamp to now
  Future<void> updateTimestampToNow() async {
    lastUpdated = DateTime.now().toIso8601String();
    await _prefs.setString(lastUpdateKey, lastUpdated!);
  }
}
