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
import 'package:positivityapp/widgets/usage_dialog.dart';
// import 'package:positivityapp/widgets/progress_dialog.dart';
import 'package:positivityapp/controllers/config_state.dart';
import 'package:positivityapp/models/stats_db.dart';
import 'package:positivityapp/utils.dart';
import 'package:positivityapp/const.dart';

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
    if (userConf.lastUpdated != null) {
      if (isItTimeYet(DateTime.now(), userConf.lastUpdated!, genPause)) {
        scenario = (await getScenario(
            client, deviceId, userConf.topics, userConf.difficulty));
        confCache.add({"textQailuty": true});
      }
    }
  }
  confCache.add({cacheKey: scenario});
  if (userConf.topics.isEmpty) {
    confCache.add({"firstTime": true});
  }
  confCache.add({"lastTrack": await lastProgress(client, deviceId)});

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
  Future<List<String?>>? _scenarioFuture;
  String? message;
  bool? feedback;
  bool timeToTck = false;

  int debugCounter = 0;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(userConf.minAnswers, (_) => TextEditingController());
    _scenarioFuture = _computeScenarioAndMaybeFetch();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<List<String?>> _fetchAndPersistNow() async {
    final now = DateTime.now();
    final res = await getScenario(
        client, deviceId, userConf.topics, userConf.difficulty);
    state.update(cacheKey, res); // keep your cache in sync
    await userConf.updatePreferences(
        null, null, null, now.toIso8601String(), null);
    state.update("textQailuty", true);
    return res;
  }

  Future<List<String?>> _computeScenarioAndMaybeFetch() async {
    // Step 1: configuration set?
    final bool configSet =
        userConf.topics.isNotEmpty && userConf.difficulty.isNotEmpty;

    if (!configSet) {
      // 1) Config not set → static message
      return ["Configure app first", null, null];
    }

    final DateTime now = DateTime.now();
    final String? last = userConf.lastUpdated;

    // Step 2: First-time configuration → fetch once, set lastUpdated
    if (last == null) {
      var res = await getScenario(
          client, deviceId, userConf.topics, userConf.difficulty);
      // cache if you keep a cache map
      state.update(cacheKey, res); // uses your existing cache holder
      await userConf.updatePreferences(
          null, null, null, now.toIso8601String(), null);
      state.update("textQailuty", true);
      return res;
    }

    // Step 3: Check isItTime (>= 3h). You already have genPause == 3 (hours).
    bool threeHoursOrMore = isItTimeYet(now, last, genPause);
    if (threeHoursOrMore) {
      // time to fetch new
      final res = await getScenario(
          client, deviceId, userConf.topics, userConf.difficulty);
      state.update(cacheKey, res);
      await userConf.updatePreferences(
          null, null, null, now.toIso8601String(), null);
      return res;
    } else {
      // not yet time → static message
      state.update("textQailuty", false);
      return ["No available scenarios yet", null, null];
    }
  }

  @override
  Widget build(BuildContext context) {
    int answers = 0;
    List<String> answersText = [];
    bool debugDevice = dotenv.env["DEBUG_DEVICE"] != null ? true : false;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    bool timeToTrack =
        isItTimeYet(DateTime.now(), state.state["lastProgress"], 24 * 7);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: FutureBuilder<List<String?>>(
            future: _scenarioFuture,
            builder:
                (BuildContext context, AsyncSnapshot<List<String?>> snapshot) {
              final String displayMessage = message ??
                  (snapshot.data?[1] ?? "No scenario currently available.");
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
                            height: height * 0.15,
                            width: width * 0.96,
                            color: Colors.blue[50],
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
                                child: Text(displayMessage,
                                    style: const TextStyle(fontSize: 18))),
                          )),
                          const SizedBox(height: 10.0),
                        ]);
                  }
                }, childCount: 1)),
                if (state.state["textQailuty"] == true)
                  SliverPadding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_down_alt_outlined,
                                color: feedback == false
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  feedback = false;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up_alt_outlined,
                                color: feedback == true
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  feedback = true;
                                });
                              },
                            ),
                          ],
                        );
                      }, childCount: 1))),
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
                            answersText.add(c.text);
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
                        await saveAnswer(
                            client, snapshot.data![0]!, answersText, feedback);
                        setState(() {
                          message = "Saved. Stay positive!";
                          state.update("textQailuty", false);
                          feedback = null;
                        });
                        // if (timeToTrack) {
                        //   showDialog(context: context, builder: (context) {
                        //     return WellbeingDialog(client: client, deviceId: deviceId);
                        //   });
                        // }
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
                      setState(() {
                        if (state.state["firstTime"] == true) {
                          message = null; // let new content show
                          _scenarioFuture = _fetchAndPersistNow();
                          state.update("firstTime", false);
                        }
                      });
                    });
                  }),
              if (debugDevice == true)
                SpeedDialChild(
                    child: const Icon(Icons.refresh),
                    label: 'New scenario',
                    backgroundColor: Colors.lightBlue.shade100,
                    onTap: () {
                      // showDialog(
                      //     context: context,
                      //     builder: (context) {
                      //       return GenDialog(count: 1);
                      //     }).then((_) {
                      // refreshAttempts += 1;
                      // noRefresh = false;
                      // _noFutureTrigger = false;
                      setState(() {
                        message = null; // let new content show
                        _scenarioFuture = _fetchAndPersistNow();
                      });
                      // });
                    }),
            ]));
  }
}
