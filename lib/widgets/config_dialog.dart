import 'package:flutter/material.dart';
import 'package:positivityapp/controllers/config_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:positivityapp/models/configuration.dart';

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

  String? _endpoints;
  int? _answers;
  final _controller = MultiSelectController<String>();
  // final List<DropdownItem> _blacklistedAreas = [];

  @override
  void initState() {
    super.initState();
    userConf = UserPreference().getPreference(prefs);
    _answers = userConf.minimumPositive;
  }

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
                                    state.update(minAnswersKey, _answers);
                                  });
                                },
                                hint: const Text('Num solutions')))
                      ]),
                      Row(children: <Widget>[
                        const Expanded(
                            child: Text("Exclude topics",
                                textAlign: TextAlign.center)),
                        Expanded(
                          child: MultiDropdown<String>(
                            items: [
                              DropdownItem(label: 'Option 1', value: '1'),
                              DropdownItem(label: 'Option 2', value: '2'),
                              DropdownItem(label: 'Option 3', value: '3'),
                              DropdownItem(label: 'Option 4', value: '4'),
                              DropdownItem(label: 'Option 5', value: '5'),
                              DropdownItem(label: 'Option 6', value: '6'),
                            ],
                            controller: _controller,
                            enabled: true,
                            onSelectionChange: (options) {
                              debugPrint(options.toString());
                            },
                            // maxSelection: 4,
                            // disabledOptions: const [DropdownItem(label: 'Option 1', value: '1')],
                            // selectionType: SelectionType.multi,
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
                              state.update(
                                  endpointsKey, endpointsDrop[_endpoints]);
                              state.update(minAnswersKey, _answers);
                              userConf.setPreference(
                                  prefs,
                                  endpointsDrop[_endpoints],
                                  _answers,
                                  null,
                                  null);
                            });
                            Navigator.of(context).pop();
                          },
                        )
                      ]),
                    ]))));
  }
}
