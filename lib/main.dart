import 'package:positivityapp/const.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:positivityapp/controllers/fetcher.dart';
import 'package:positivityapp/controllers/dbhandler.dart';
import 'package:positivityapp/models/configuration.dart';
import 'package:positivityapp/widgets/config_dialog.dart';
// import 'package:positivityapp/widgets/info_dialog.dart';
import 'package:positivityapp/widgets/usage_dialog.dart';
// import 'package:positivityapp/widgets/generation_dialog.dart';
import 'package:positivityapp/controllers/config_state.dart';
import 'package:positivityapp/models/stats_db.dart';

const String cacheKey = "cachedScenario";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var client = http.Client();
  await dotenv.load(fileName: ".env");
  Database db = await DatabaseHandler().initializeDB();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  String deviceId = androidInfo.id;
  UserConfigCache confCache = UserConfigCache();
  UserConfiguration userConf = await UserConfiguration.getInstance();
// TBD: re-designed persistent storage for pre-cached scenarios on set configuration
  List<String?> scenario = [
    "Set up your level and areas to start excercise",
    null,
    null
  ];
  if (userConf.topics.isNotEmpty & userConf.difficulty.isNotEmpty) {
    scenario = (await getScenario(
        client, deviceId, userConf.topics, userConf.difficulty));
  }
  confCache.add({cacheKey: scenario});
  runApp(MyApp(
      config: userConf,
      client: client,
      deviceId: deviceId,
      state: confCache,
      db: db));
}

class MyApp extends StatelessWidget {
  final UserConfiguration config;
  final http.Client client;
  final String deviceId;
  final UserConfigCache state;
  final Database db;
  const MyApp(
      {required this.config,
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
          config: config,
          client: client,
          deviceId: deviceId,
          state: state,
          db: db),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final UserConfiguration config;
  final http.Client client;
  final String deviceId;
  final UserConfigCache state;
  final Database db;
  const MyHomePage({
    super.key,
    required this.title,
    required this.config,
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
  UserConfiguration get userConf => widget.config;
  http.Client get client => widget.client;
  String get deviceId => widget.deviceId;
  UserConfigCache get state => widget.state;
  Database get db => widget.db;
  late List<TextEditingController> _controllers;
  bool _isCollectingText =
      false; // work-around TextField fetching future builder triggering multipe times
  DateTime lastUpdate = DateTime.now();
  String noYetAvailableText = "No new scenario for now!";
  late String cachedScenario;

  int debugCounter = 0;

  void setTextControllers(int number) {
    _controllers = [];
    for (var i = 0; i < userConf.minAnswers; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void initState() {
    super.initState();
    setTextControllers(userConf.minAnswers);
  }

  Future<List<String?>> _getText() async {
    /**
    Generating text using different logical checks:
    - is it the first session -> config is not set and generation not possible, normally would be called once
    - config update on the initial setup -> one-off trigger of config update TBD
    - your previous text generation was Xh ago -> timestamp of the last generation is old, fetch based on config

    **/
    bool isFirstTime = userConf.topics.isEmpty;
    DateTime tryNow = DateTime.now();
    bool isItTime = false;
    if (userConf.lastUpdated != null) {
      isItTime =
          tryNow.difference(DateTime.parse(userConf.lastUpdated!)).inHours >=
              genPause;
    } else {
      await userConf.updatePreferences(
          null, null, null, tryNow.toIso8601String(), null);
      isItTime = true;
    }

    // actual logic
    // Is it a first timer -> is it time to answers
    try {
      if (isFirstTime) {
        // no confiug set, we show inital message
        return ["Configure preferences before starting excercise", null, null];
      } else {
        // config is set, now checking if the time is right and it's not a widget trigger
        if (isItTime) {
          var res = (await getScenario(
              client, deviceId, userConf.topics, userConf.difficulty));
          // state.update(cacheKey, res);
          return res;
        } else {
          return ["Next session will start soon!", null, null];
        }
      }
    } catch (e) {
      FlutterError("Could not fetch a scenario due to ${e}");
      return ["No scenario is currently available.", null, null];
    }

    try {
      if (_isCollectingText == true) {
        // is config set?
        if (isFirstTime) {
          print("First timer");
          return state.state[cacheKey];
        } // TBD: explicit hardcoded return value? should only happen on clean start
        else {
          if (isItTime) {
            var res = (await getScenario(
                client, deviceId, userConf.topics, userConf.difficulty));
            state.update(cacheKey, res);
            print("Got first time sceanrio ${res}");
            return res;
          } else {
            return ["Have to wait a bit for the new task!", null, null];
          }
        }
      } else {
        print("Collecting text ${_isCollectingText}");
        return ["No available scenarios yet!", null, null];
      }
    } catch (e) {
      FlutterError("{e}");
      return ["Something is wrong", null, null];
    } finally {
      setState(() {
        _isCollectingText = false;
      });
    }

    // first-time open -> userConf.topics are not set
    // if (isFirstTime) {
    //   return [cachedScenario, null, null];
    // } else {
    //   if (userConf.lastUpdated == null) {
    //     // first time generation after cofig setup
    //     var res = (await getScenario(
    //         client, deviceId, userConf.topics, userConf.difficulty));
    //     await userConf.updatePreferences(
    //         null, null, null, tryNow.toIso8601String(), null);
    //     return res;
    //   }
    //   // config is set and it's first generation or last generation was X hours ago
    //   if (isItTime) {
    //     await userConf.updatePreferences(
    //         null, null, null, tryNow.toIso8601String(), null);
    //     return res;
    //   } else {
    //     return [noYetAvailableText, null, null];
    //   }
    // }

    // if (_noFutureTrigger == false || isTimeToUpdate()) {
    //   _noFutureTrigger = true;
    //   lastUpdate = DateTime.now();
    //   // Not sure if it's the best place, but we need to check often enough when the next day is
    //   String today = getTodayAsString();
    //   if (today != usage.date) {
    //     await usage.setUsage(prefs, today, 2);
    //   }
    //   bool noManualRefreshes =
    //       usage.refreshCount == 0 || refreshAttempts > usage.refreshCount!;
    //   // Caused either by limits hit or some dialog trigger that should not fetch a new text
    //   if (noRefresh == true) {
    //     String text =
    //         noManualRefreshes == true ? noTextAvailable : cachedScenario;
    //     return [text, "None", "None"];
    //   } else {
    //     if (noManualRefreshes == false) {
    //       var res = await getScenario(
    //           client, deviceId, userConf.topics, userConf.difficulty);
    //       cachedScenario = res[0];
    //       return res;
    //     }
    //     return [noTextAvailable, "None", "None"];
    //   }
    // }
    // return [cachedScenario, "None", "None"];
  }

  @override
  Widget build(BuildContext context) {
    int answers = 0;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: _getText(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String?>> snapshot) {
              return CustomScrollView(slivers: [
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
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
                  }
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
                    }, childCount: userConf.minAnswers))),
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
                        setState(() {
                          _isCollectingText = true;
                        });
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
              // SpeedDialChild(
              //     child: const Icon(Icons.help),
              //     label: 'Info',
              //     backgroundColor: Colors.lightBlue.shade300,
              //     onTap: () {
              //       showDialog(
              //           context: context,
              //           builder: (context) {
              //             return const InfoDialog();
              //           });
              //     }),
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
                          return ConfigDialog(config: userConf, state: state);
                        }).then((_) {
                      // noRefresh = true;
                      setState(() {});
                    });
                  }),
              // SpeedDialChild(
              //     child: const Icon(Icons.refresh),
              //     label: 'New scenario',
              //     backgroundColor: Colors.lightBlue.shade100,
              //     onTap: () {
              //       showDialog(
              //           context: context,
              //           builder: (context) {
              //             return GenDialog(count: leftRefresh, prefs: prefs);
              //           }).then((_) {
              //         refreshAttempts += 1;
              //         noRefresh = false;
              //         _noFutureTrigger = false;
              //         setState(() {});
              //       });
              //     }),
            ]));
  }
}
