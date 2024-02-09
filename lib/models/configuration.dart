class UserPreference {
  List<String> areaBacklist = [];
  List<String> difficultyBlacklist = [];
  int endpointToUse;
  int minimumPositive = 2;
  bool pause = false;
  String timeFrame = "None";
  int numberReminders = 3;

  UserPreference(
      {this.difficultyBlacklist,
      this.areaBlacklist,
      required this.endpointToUse,
      this.minimumPositive,
      this.pause,
      this.timeFrame,
      this.numberReminders});
}
