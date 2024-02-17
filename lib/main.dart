import 'package:flutter/material.dart';
import 'package:positivityapp/models/configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:positivityapp/widgets/config_dialog.dart';
import 'package:positivityapp/widgets/info_dialog.dart';
import 'package:positivityapp/widgets/generation_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:positivityapp/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var client = http.Client();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // BaseDeviceInfo devInfo = await deviceInfo.deviceInfo; // TODO: from here define which OS it is and get Id
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  String deviceId = androidInfo.id;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs, client: client, deviceId: deviceId));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final http.Client client;
  final String deviceId;
  const MyApp(
      {required this.prefs,
      required this.client,
      required this.deviceId,
      super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PotivityTraining',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
          title: 'PositivityApp',
          prefs: prefs,
          client: client,
          deviceId: deviceId),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final SharedPreferences prefs;
  final http.Client client;
  final String deviceId;
  const MyHomePage(
      {super.key,
      required this.title,
      required this.prefs,
      required this.client,
      required this.deviceId});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // const
  SharedPreferences get prefs => widget.prefs;
  http.Client get client => widget.client;
  String get deviceId => widget.deviceId;
  List<String> tags = ["social", "family", "romantic", "health", "career"];
  List<String> difficulty = ["simple", "neutral", "hard"];
  late UserPreference userConf;

  @override
  void initState() {
    super.initState();
    userConf = UserPreference().getPreference(prefs);
  }

  Future<String> _getText() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${Env.auth}',
    };
    var url = Uri.parse(
        "${Env.base_url}/api/v2/negative_scenario/$deviceId?difficulty=Difficult&area=Health");
    var res = await client.get(url, headers: headers);
    return res.body;
    // return "LOL!";
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: _getText(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return CustomScrollView(slivers: [
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                            child: Text("Life Scenario:",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold))),
                        Center(
                            child: Container(
                          height: height * 0.3,
                          width: width * 0.9,
                          color: Colors.blue[50],
                          child: Text(snapshot.data.toString(),
                              style: const TextStyle(fontSize: 18)),
                        )),
                      ]);
                }, childCount: 1)),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                  return const Center(
                      child: Text("Optimistic views:",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)));
                }, childCount: 1)),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                  return const Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: TextField(
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Optimistic/Positive outlook',
                          )));
                }, childCount: userConf.minimumPositive))
              ]);
            }),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: SpeedDial(
            icon: Icons.account_circle,
            backgroundColor: Colors.lightBlue.shade100,
            children: [
              SpeedDialChild(
                  child: const Icon(Icons.help),
                  label: 'Info',
                  backgroundColor: Colors.lightBlue.shade300,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const InfoDialog();
                        }).then((_) {
                      setState(() {});
                    });
                  }),
              SpeedDialChild(
                  child: const Icon(Icons.build),
                  label: 'Config',
                  backgroundColor: Colors.lightBlue.shade200,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ConfigDialog(prefs: prefs);
                        }).then((_) {
                      setState(() {});
                    });
                  }),
              SpeedDialChild(
                  child: const Icon(Icons.refresh),
                  label: 'New scenario',
                  backgroundColor: Colors.lightBlue.shade100,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const GenDialog();
                        }).then((_) {
                      setState(() {});
                    });
                  }),
            ]));
  }
}
