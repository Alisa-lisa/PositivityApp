import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:positivityapp/models/configuration.dart';

class ConfigDialog extends StatefulWidget {
  const ConfigDialog({super.key});

  @override
  ConfigDialogState createState() => ConfigDialogState();
}

class ConfigDialogState extends State<ConfigDialog> {
  UserPreference userConf = UserPreference();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var conf = UserPreference();
    conf.endpointToUse = 2;
    print("${conf.areaBlacklist}");
    return const Dialog(
        child: Column(children: [Text("Here comes configuration")]));
  }
}
