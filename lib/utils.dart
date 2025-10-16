bool isItTimeYet(DateTime now, String? last, int difference) {
  if (last != null) {
    return now.difference(DateTime.parse(last)).inHours >= difference;
  } else {
    return true;
  }
}
