import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Currently hardcoded, dectated from BE values. In the future should be handled by openAPI specs
const List<String> areas = [
  "social",
  "career",
  "romantic",
  "personal",
  "health"
];
// const List<double> AREA_WEIGHT = [];
const List<String> difficulty = [
  "slightly negative",
  "challenging",
  "devastating"
];
const List<double> difWeight = [0.75, 0.25, 0.05];
String? baseUrl = dotenv.env["SERVER"];
String? auth = dotenv.env["AUTH"];

Future<List<String>> getScenario(http.Client client, String deviceId) async {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'access': auth!,
  };
  String area = randomChoice<String>(areas);
  String dif = randomChoice<String>(difficulty, difWeight);
  var url = Uri.parse(
      "${baseUrl!}/textgen/negative_scenario/$deviceId?lvl=$dif&area=$area");
  var res = await client.get(url, headers: headers);
  return [res.body, dif, area];
}
