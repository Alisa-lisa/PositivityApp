import 'package:sqflite/sqflite.dart';
import 'package:positivityapp/controllers/dbhandler.dart';
import 'package:flutter/material.dart';
import 'package:positivityapp/controllers/fetcher.dart';
import 'package:positivityapp/models/configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

import 'package:positivityapp/widgets/config_dialog.dart';
import 'package:positivityapp/widgets/info_dialog.dart';
import 'package:positivityapp/widgets/usage_dialog.dart';
import 'package:positivityapp/widgets/generation_dialog.dart';
import 'package:positivityapp/controllers/config_state.dart';
import 'package:positivityapp/models/usage.dart';
import 'package:positivityapp/models/stats_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var client = http.Client();
  Database db = await DatabaseHandler().initializeDB();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // BaseDeviceInfo devInfo = await deviceInfo.deviceInfo; // TODO: from here define which OS it is and get Id
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  String deviceId = androidInfo.id;
  UserConfigCache confCache = UserConfigCache();
  confCache.add({"cache": (await getScenario(client, deviceId, 1))});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
      prefs: prefs,
      client: client,
      deviceId: deviceId,
      state: confCache,
      db: db));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final http.Client client;
  final String deviceId;
  final UserConfigCache state;
  final Database db;
  const MyApp(
      {required this.prefs,
      required this.client,
      required this.deviceId,
      required this.state,
      required this.db,
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
          deviceId: deviceId,
          state: state,
          db: db),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final SharedPreferences prefs;
  final http.Client client;
  final String deviceId;
  final UserConfigCache state;
  final Database db;
  const MyHomePage({
    super.key,
    required this.title,
    required this.prefs,
    required this.client,
    required this.state,
    required this.deviceId,
    required this.db,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // const
  SharedPreferences get prefs => widget.prefs;
  http.Client get client => widget.client;
  String get deviceId => widget.deviceId;
  UserConfigCache get state => widget.state;
  Database get db => widget.db;
  late UserPreference userConf;
  late UsageStats usage;
  late List<TextEditingController> _controllers;
  bool noRefresh = true;
  // work-around TextField fetching future builder triggering multipe times
  bool _noFutureTrigger = true;
  DateTime lastUpdate = DateTime.now();
  int refreshCounter = 0;
  String noTextAvailable = "No new scenario for now!";
  late String cachedScenario;

  int debugCounter = 0;

  void setTextControllers(int number) {
    _controllers = [];
    for (var i = 0; i < state.state[minAnswersKey]; i++) {
      _controllers.add(TextEditingController());
    }
  }

  bool isTimeToUpdate() {
    return lastUpdate.difference(DateTime.now()).inMinutes > 60;
  }

  @override
  void initState() {
    super.initState();
    _noFutureTrigger = false;
    usage = UsageStats().getUsage(prefs);
    userConf = UserPreference().getPreference(prefs);
    state.add({
      endpointsKey: 1,
      // endpointsKey: userConf.endpointToUse,
      minAnswersKey: userConf.minimumPositive,
      remindersKey: userConf.numberReminders,
      pauseKey: userConf.pause
    });
    noRefresh = false;
    setTextControllers(state.state[minAnswersKey]);
  }

  Future<List<String>> _getText() async {
    if (_noFutureTrigger == false || isTimeToUpdate()) {
      _noFutureTrigger = true;
      lastUpdate = DateTime.now();
      // Not sure if it's the best place, but we need to check often enough when the next day is
      String today = getTodayAsString();
      if (today != usage.date) {
        await usage.setUsage(prefs, today, 2);
      }
      bool noManualRefreshes =
          usage.refreshCount == 0 || refreshCounter > usage.refreshCount!;
      // Caused either by limits hit or some dialog trigger that should not fetch a new text
      if (noRefresh == true) {
        String text =
            noManualRefreshes == true ? noTextAvailable : cachedScenario;
        return [text, "None", "None"];
      } else {
        if (noManualRefreshes == false) {
          var res =
              await getScenario(client, deviceId, state.state[endpointsKey]);
          // debugCounter += 1;
          // var res = "Calling backend $debugCounter";
          cachedScenario = res[0];
          return res;
        }
        return [noTextAvailable, "None", "None"];
      }
    }
    return [cachedScenario, "None", "None"];
  }

  @override
  Widget build(BuildContext context) {
    int answers = 0;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    int leftRefresh = usage.refreshCount! - refreshCounter >= 0
        ? usage.refreshCount! - refreshCounter
        : 0;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: _getText(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
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
                          width: width * 0.96,
                          color: Colors.blue[50],
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
                              child: Text(snapshot.data![0].toString(),
                                  style: const TextStyle(fontSize: 18))),
                        )),
                        const SizedBox(height: 16.0),
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
                SliverPadding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: TextField(
                          controller: _controllers[index],
                          obscureText: false,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'your idea'),
                        ),
                      );
                    }, childCount: state.state[minAnswersKey]))),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        for (var c in _controllers) {
                          if (c.text.isNotEmpty) {
                            answers += 1;
                          }
                          c.clear();
                        }
                        await Stats.write(
                            db,
                            Stats(
                                time: DateTime.now().toString(),
                                input: snapshot.data![0].toString(),
                                difficulty: snapshot.data![1].toString(),
                                area: snapshot.data![2].toString(),
                                count: answers));
                        lastUpdate = DateTime.now();
                        cachedScenario = "Good job! Stay positive!";
                        setState(() {});
                      },
                      child: const Text('Go'),
                    ),
                  );
                }, childCount: 1)),
              ]);
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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
                        });
                  }),
              SpeedDialChild(
                  child: const Icon(Icons.fact_check),
                  label: 'Usage',
                  backgroundColor: Colors.lightBlue.shade300,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const UsageGuidanceDialog();
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
                          return ConfigDialog(prefs: prefs, state: state);
                        }).then((_) {
                      noRefresh = true;
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
                          return GenDialog(count: leftRefresh, prefs: prefs);
                        }).then((_) {
                      refreshCounter += 1;
                      noRefresh = false;
                      _noFutureTrigger = false;
                      setState(() {});
                    });
                  }),
            ]));
  }
}
