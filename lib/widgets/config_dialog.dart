import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:positivityapp/models/configuration.dart';

class ConfigDialog extends StatefulWidget {
  final SharedPreferences prefs;
  const ConfigDialog({super.key, required this.prefs});

  @override
  ConfigDialogState createState() => ConfigDialogState();
}

class ConfigDialogState extends State<ConfigDialog> {
  SharedPreferences get prefs => widget.prefs;
  late UserPreference userConf;

  String? _endpoints;
  int? _answers;
  int? _reminders;
  bool? _pause;

  @override
  void initState() {
    super.initState();
    userConf = UserPreference().getPreference(prefs);
    _endpoints = endpointsRevers[userConf.endpointToUse];
    _answers = userConf.minimumPositive;
    _reminders = userConf.numberReminders;
    _pause = userConf.pause;
  }

  Map<String, int> endpointsDrop = {"All": 2, "Closed": 0, "OpenAI": 1};
  Map<int, String> endpointsRevers = {2: "All", 0: "Closed", 1: "OpenAI"};

  List<DropdownMenuItem<String>> getDDItems() {
    List<DropdownMenuItem<String>> res = [];
    res.addAll(endpointsDrop.keys
        .toList()
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value));
    }).toList());
    return res;
  }

  List<DropdownMenuItem<int>> getNumAnswers() {
    List<DropdownMenuItem<int>> res = [];
    res.addAll([1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
      return DropdownMenuItem<int>(value: value, child: Text(value.toString()));
    }).toList());
    return res;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Dialog(
        child: SingleChildScrollView(
            child: SizedBox(
                width: width * 0.9,
                height: height * 0.8,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Configuration"),
                      Row(children: [
                        const Expanded(
                            child:
                                Text("Endpoits", textAlign: TextAlign.center)),
                        Expanded(
                            child: DropdownButton<String>(
                                focusColor: Colors.white,
                                value: _endpoints,
                                items: getDDItems(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _endpoints = value!;
                                  });
                                },
                                hint: const Text('Text gen')))
                      ]),
                      Row(children: [
                        const Expanded(
                            child: Text("Min answers",
                                textAlign: TextAlign.center)),
                        Expanded(
                            child: DropdownButton<int>(
                                focusColor: Colors.white,
                                value: _answers,
                                items: getNumAnswers(),
                                onChanged: (int? value) {
                                  setState(() {
                                    _answers = value!;
                                  });
                                },
                                hint: const Text('Num solutions')))
                      ]),
                      Row(children: [
                        const Expanded(
                            child: Text("Daily reminders",
                                textAlign: TextAlign.center)),
                        Expanded(
                            child: DropdownButton<int>(
                                focusColor: Colors.white,
                                value: _reminders,
                                items: getNumAnswers(),
                                onChanged: (int? value) {
                                  setState(() {
                                    _reminders = value!;
                                  });
                                },
                                hint: const Text('Reminders per day')))
                      ]),
                      Row(children: [
                        const Expanded(
                            child: Text(
                          "Pause reminders",
                          textAlign: TextAlign.center,
                        )),
                        Expanded(
                            child: Switch(
                          value: _pause!,
                          activeColor: Colors.blue,
                          onChanged: (bool value) {
                            setState(() {
                              _pause = value;
                            });
                          },
                        ))
                      ]),
                      Stack(children: [
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF1976D2),
                                  Color(0xFF42A5F5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          child: const Text("Save"),
                          onPressed: () {
                            setState(() {
                              userConf.setPreference(
                                  prefs,
                                  endpointsDrop[_endpoints],
                                  _answers,
                                  _pause,
                                  _reminders);
                            });
                            Navigator.of(context).pop();
                          },
                        )
                      ]),
                    ]))));
  }
}
