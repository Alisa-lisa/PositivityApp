import 'package:positivityapp/const.dart';

bool isItTimeYet(DateTime now, String last) {
  return now.difference(DateTime.parse(last)).inHours >= genPause;
}
