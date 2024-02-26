import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:positivityapp/env/env.dart';
import 'package:http/http.dart' as http;

// Currently hardcoded, dectated from BE values. In the future should be handled by openAPI specs
const List<String> areas = ["Social", "Health", "Career", "Romantic", "Family"];
// const List<double> AREA_WEIGHT = [];
const List<String> difficulty = ["Difficult", "Simple", "Neutral"];
const List<double> difWeight = [0.75, 0.25, 0.05];

Future<String> getScenario(http.Client client, String deviceId) async {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${Env.auth}',
  };
  String area = randomChoice<String>(areas);
  String dif = randomChoice<String>(difficulty, difWeight);
  var url = Uri.parse(
      "${Env.server}/api/v2/negative_scenario/$deviceId?difficulty=$dif&area=$area");
  var res = await client.get(url, headers: headers);
  return res.body;
}
