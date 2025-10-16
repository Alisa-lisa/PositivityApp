import 'package:format/format.dart';

bool isItTimeYet(DateTime now, String? last, int difference) {
  if (last != null) {
    try {
      // last = last.split(".")[0];
      last = last.replaceAll('"', '');
      var d = DateTime.parse(last);
      return now.difference(d).inHours >= difference;
    } catch (e) {
      throw Exception(format("Could not fetch data due to {}", e));
    }
  } else {
    return true;
  }
}
