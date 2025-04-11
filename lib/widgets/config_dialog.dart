import 'package:flutter/material.dart';
import 'package:positivityapp/controllers/config_state.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:positivityapp/models/configuration.dart';
import 'package:positivityapp/const.dart';

class ConfigDialog extends StatefulWidget {
  final UserConfiguration config;
  final UserConfigCache state;
  const ConfigDialog({super.key, required this.config, required this.state});

  @override
  ConfigDialogState createState() => ConfigDialogState();
}

class ConfigDialogState extends State<ConfigDialog> {
  UserConfigCache get state => widget.state;
  UserConfiguration get userConf => widget.config;

  final _topics = MultiSelectController<String>();
  final _level = MultiSelectController<String>();

  @override
  void initState() {
    super.initState();
  }

  List<DropdownMenuItem<int>> getNumAnswers() {
    List<DropdownMenuItem<int>> res = [];
    res.addAll([1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
      return DropdownMenuItem<int>(value: value, child: Text(value.toString()));
    }).toList());
    return res;
  }

  List<DropdownItem<String>> prepareDropdown(
      List<String> rawInput, List<String> refernce) {
    List<DropdownItem<String>> res = [];
    for (var item in rawInput) {
      bool isSelected = refernce.contains(item);
      res.add(DropdownItem(label: item, value: item, selected: isSelected));
    }
    return res;
  }

  void _handleSelectedTopics(List<String> options) async {
    await userConf.updatePreferences(options, null, null, null, null);
  }

  void _handleSelectedDifficulty(List<String> options) async {
    await userConf.updatePreferences(null, options, null, null, null);
  }

  Widget _getDropdownRow(
      String header,
      MultiSelectController<String> controller,
      List<DropdownItem<String>> items,
      Function onSelect) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
              flex: 20,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Text(header, textAlign: TextAlign.center))),
          SizedBox(width: 5),
          Flexible(
            flex: 80,
            child: MultiDropdown<String>(
              items: items,
              controller: controller,
              enabled: true,
              searchEnabled: true,
              onSelectionChange: (options) {
                onSelect(options);
              },
              chipDecoration: const ChipDecoration(
                backgroundColor: Colors.yellow,
                wrap: true,
                runSpacing: 2,
                spacing: 8,
              ),
            ),
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Dialog(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width * 0.9,
              maxHeight: height * 0.6,
            ),
            child: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.all(10),
                    child: IntrinsicWidth(
                        child: Column(children: [
                      const SizedBox(height: 12),
                      const Text(
                        "User Configuration",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      _getDropdownRow(
                          "Topics:",
                          _topics,
                          prepareDropdown(areas, userConf.topics),
                          _handleSelectedTopics),
                      const SizedBox(height: 24),
                      _getDropdownRow(
                          "Level:",
                          _level,
                          prepareDropdown(difficulty, userConf.difficulty),
                          _handleSelectedDifficulty),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Stack(children: [
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
                              // Simple update force
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          )
                        ]),
                      )
                    ]))))));
  }
}
