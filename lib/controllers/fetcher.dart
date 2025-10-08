import 'dart:convert';
import 'package:format/format.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String? base = dotenv.env["SERVER"];
String? auth = dotenv.env["AUTH"];
String baseUri = format("{}/textgen", base!);
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'access': auth!,
};

Future<List<String>> getScenario(http.Client client, String deviceId,
    List<String> topics, List<String> lvl) async {
  String area = randomChoice<String>(topics);
  String dif = randomChoice<String>(lvl);
  String url = format(
      "{}/negative_scenario/{}?lvl={}&area={}", baseUri, deviceId, dif, area);
  var resp = await client.get(Uri.parse(url), headers: headers);
  Map<String, dynamic> payload = jsonDecode(resp.body);
  print("This is payload: ${payload}");
  return [payload["id"], payload["text"], dif, area];
}
