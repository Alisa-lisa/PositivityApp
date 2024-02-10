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

  @override
  void initState() {
    super.initState();
    userConf = UserPreference().getPreference(prefs);
  }

  @override
  Widget build(BuildContext context) {
    print("${userConf.areaBlacklist}");
    return const Dialog(
        child: Column(children: [Text("Here comes configuration")]));
  }
}
