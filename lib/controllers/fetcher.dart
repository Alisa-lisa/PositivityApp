import 'dart:convert';
import 'package:format/format.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String? base = dotenv.env["SERVER"];
String? auth = dotenv.env["AUTH"];
String genBase = format("{}/textgen", base!);
String trackBase = format("{}/analysis", base!);
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'access': auth!,
};

Future<List<String>> getScenario(http.Client client, String deviceId,
    List<String> topics, List<String> lvl) async {
  String area = randomChoice<String>(topics);
  String dif = randomChoice<String>(lvl);
  String url = format(
      "{}/negative_scenario/{}?lvl={}&area={}", genBase, deviceId, dif, area);
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

Future<String> saveAnswer(http.Client client, String requestId,
    List<String> answers, bool? satisfaction) async {
  String url = format("{}/answer/{}", genBase, requestId);
  Map<String, dynamic> payload = {
    "answers": answers,
    "satisfaction": satisfaction
  };
  try {
    var resp = await client.post(Uri.parse(url),
        headers: headers, body: jsonEncode(payload));
    if (resp.statusCode == 200) {
      return resp.body;
    } else {
      throw Exception("Could not save answers");
    }
  } catch (e) {
    throw Exception(format("Coudl not save answers due to {}", e));
  }
}

Future<String> lastProgress(http.Client client, String deviceId) async {
  String url = format("{}/tracking/{}", trackBase, deviceId);
  try {
    var resp = await client.get(Uri.parse(url), headers: headers);
    if (resp.statusCode == 200) {
      return resp.body;
    } else {
      throw Exception("Could not get last submission");
    }
  } catch (e) {
    throw Exception(format("Could not fetch last submission due to {}", e));
  }
}

Future<bool> saveProgress(
    http.Client client,
    String deviceId,
    int mood,
    int stress,
    int resil,
    int general,
    int social,
    int career,
    bool? negatives,
    bool? positives,
    String? feedback) async {
  String url = format("{}/tracking/{}", trackBase, deviceId);
  try {
    Map<String, dynamic> body = {
      "mood": mood,
      "stress": stress,
      "resilience": resil,
      "general_satisfaction": general,
      "social_satisfaction": social,
      "career_satisfaction": career,
      "negative_events": negatives,
      "positive_events": positives,
      "feedback": feedback
    };
    var resp = await client.post(Uri.parse(url),
        headers: headers, body: jsonEncode(body));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception("Could not save progress");
    }
  } catch (e) {
    throw Exception(format("Could not save progress due to {}", e));
  }
}
