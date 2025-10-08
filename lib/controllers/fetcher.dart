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
  try {
    var resp = await client.get(Uri.parse(url), headers: headers);
    if (resp.statusCode == 200) {
      Map<String, dynamic> payload = jsonDecode(resp.body);
      return [payload["id"], payload["text"], dif, area];
    } else {
      throw Exception("Could not fetch scenario");
    }
  } catch (e) {
    throw Exception(format("Could not fetch scenario due to {}", e));
  }
}

Future<String> saveAnswer(
    http.Client client, String requestId, List<String> answers) async {
  String url = format("{}/answer/{}", baseUri, requestId);
  try {
    var resp = await client.post(Uri.parse(url),
        headers: headers, body: jsonEncode(answers));
    if (resp.statusCode == 200) {
      return resp.body;
    } else {
      throw Exception("Could not save answers");
    }
  } catch (e) {
    throw Exception(format("Coudl not save answers due to {}", e));
  }
}
