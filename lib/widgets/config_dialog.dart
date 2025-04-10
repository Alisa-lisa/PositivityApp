import 'package:flutter/material.dart';
import 'package:positivityapp/controllers/config_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:positivityapp/models/configuration.dart';
import 'package:positivityapp/const.dart';

class ConfigDialog extends StatefulWidget {
  final SharedPreferences prefs;
  final UserConfigCache state;
  const ConfigDialog({super.key, required this.prefs, required this.state});

  @override
  ConfigDialogState createState() => ConfigDialogState();
}

class ConfigDialogState extends State<ConfigDialog> {
  UserConfigCache get state => widget.state;
  SharedPreferences get prefs => widget.prefs;
  late UserPreference userConf;

  final _topics = MultiSelectController<String>();
  final _level = MultiSelectController<String>();

  @override
  void initState() {
    super.initState();
    userConf = UserPreference().getPreference(prefs);
  }

  List<DropdownMenuItem<int>> getNumAnswers() {
    List<DropdownMenuItem<int>> res = [];
    res.addAll([1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
      return DropdownMenuItem<int>(value: value, child: Text(value.toString()));
    }).toList());
    return res;
  }

  List<DropdownItem<String>> prepareDropdown(List<String> rawInput) {
    List<DropdownItem<String>> res = [];
    for (var item in rawInput) {
      bool isSelected = userConf.topics.contains(item);
      res.add(DropdownItem(label: item, value: item, selected: isSelected));
    }
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
                height: height * 0.6,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Configuration"),
                      Row(children: <Widget>[
                        const Expanded(
                            child: Text("Topics", textAlign: TextAlign.center)),
                        Expanded(
                          child: MultiDropdown<String>(
                            items: prepareDropdown(areas),
                            controller: _topics,
                            enabled: true,
                            searchEnabled: true,
                            onSelectionChange: (options) {
                              userConf.setPreference(prefs, options, []);
                            },
                            chipDecoration: const ChipDecoration(
                              backgroundColor: Colors.yellow,
                              wrap: true,
                              runSpacing: 2,
                              spacing: 10,
                            ),
                            // dropdownHeight: 300,
                            // optionTextStyle: const TextStyle(fontSize: 16),
                            // selectedOptionIcon: const Icon(Icons.check_circle),
                          ),
                        )
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
                              // userConf.setPreference(
                              //     prefs, null, null, null, null);
                            });
                            Navigator.of(context).pop();
                          },
                        )
                      ]),
                    ]))));
  }
}
