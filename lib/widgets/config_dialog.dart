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

  @override
  void initState() {
    super.initState();
    userConf = UserPreference().getPreference(prefs);
    _endpoints = endpointsRevers[userConf.endpointToUse];
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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Dialog(
        child: SingleChildScrollView(
            child: SizedBox(
                width: width * 0.9,
                height: height * 0.8,
                child: Column(children: [
                  const Text("Configuration"),
                  Row(children: [
                    const Expanded(
                        child: Text("Endpoits", textAlign: TextAlign.center)),
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
                  // Row(),
                  // Row(),
                  TextButton(
                    child: const Text("Save"),
                    onPressed: () {
                      setState(() {
                        userConf.setPreference(
                            prefs, endpointsDrop[_endpoints], null, null, null);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ]))));
  }
}
