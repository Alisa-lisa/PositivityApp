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
import 'package:positivityapp/widgets/progress_dialog.dart';
import 'package:positivityapp/widgets/login.dart';
import 'package:positivityapp/controllers/config_state.dart';
import 'package:positivityapp/models/stats_db.dart';
import 'package:positivityapp/utils.dart';
import 'package:positivityapp/const.dart';

const String cacheKey = "cachedScenario";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = http.Client();

  await dotenv.load(fileName: ".env");

  final Database db = await DatabaseHandler().initializeDB();

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final String deviceId = androidInfo.id;

  final UserConfigCache confCache = UserConfigCache();
  final UserConfiguration userConf = await UserConfiguration.getInstance();

  // Important: do NOT fetch scenario in main().
  // Login check must happen first inside MyHomePage.
  confCache.add({
    cacheKey: [
      "Set up your level and areas to start exercise",
      null,
      null,
      null,
    ],
  });

  confCache.add({"textQuality": false});

  if (userConf.topics.isEmpty) {
    confCache.add({"firstTime": true});
  }

  // This call is okay; it is tracking-related, not scenario generation.
  confCache.add({"lastTrack": await lastProgress(client, deviceId)});

  runApp(
    MyApp(
      config: userConf,
      client: client,
      deviceId: deviceId,
      state: confCache,
      db: db,
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserConfiguration config;
  final http.Client client;
  final String deviceId;
  final UserConfigCache state;
  final Database db;

  const MyApp({
    required this.config,
    required this.client,
    required this.deviceId,
    required this.state,
    required this.db,
    super.key,
  });

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
        db: db,
      ),
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
  UserConfiguration get userConf => widget.config;
  http.Client get client => widget.client;
  String get deviceId => widget.deviceId;
  UserConfigCache get state => widget.state;
  Database get db => widget.db;

  late Future<bool> _loginCheckFuture;
  late List<TextEditingController> _controllers;

  Future<List<String?>>? _scenarioFuture;

  String? message;
  bool? feedback;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      userConf.minAnswers,
      (_) => TextEditingController(),
    );

    // Important: only login check starts here.
    // Scenario fetch starts only after loggedIn == true.
    _loginCheckFuture = checkLogin(client, deviceId);
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
      client,
      deviceId,
      userConf.topics,
      userConf.difficulty,
    );

    state.update(cacheKey, res);

    await userConf.updatePreferences(
      null,
      null,
      null,
      now.toIso8601String(),
      null,
    );

    state.update("textQuality", true);

    return res;
  }

  Future<List<String?>> _computeScenarioAndMaybeFetch() async {
    final bool configSet =
        userConf.topics.isNotEmpty && userConf.difficulty.isNotEmpty;

    if (!configSet) {
      state.update("textQuality", false);
      return ["Configure app first", null, null, null];
    }

    final DateTime now = DateTime.now();
    final String? last = userConf.lastUpdated;

    if (last == null) {
      return _fetchAndPersistNow();
    }

    final bool threeHoursOrMore = isItTimeYet(now, last, genPause);

    if (threeHoursOrMore) {
      return _fetchAndPersistNow();
    }

    state.update("textQuality", false);
    return ["No available scenarios yet", null, null, null];
  }

  void _showLoginSucceeded() {
    setState(() {
      _loginCheckFuture = Future.value(true);
      _scenarioFuture = _computeScenarioAndMaybeFetch();
      state.update("lastTrack", DateTime.now().toIso8601String());
    });
  }

  Widget _buildLogin() {
    return LoginForm(
      client: client,
      deviceId: deviceId,
      onDone: () async {
        _showLoginSucceeded();
      },
    );
  }

  Widget _buildHome(BuildContext context) {
    int answers = 0;
    List<String> answersText = [];

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final lastTrack = state.state["lastTrack"];
    final bool timeToTrack = lastTrack == null
        ? true
        : isItTimeYet(DateTime.now(), lastTrack, 24 * 7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<String?>>(
        future: _scenarioFuture,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<String?>> snapshot,
        ) {
          final String displayMessage = message ??
              snapshot.data?[0] ??
              "No scenario currently available.";

          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Life Scenario:",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            height: height * 0.15,
                            width: width * 0.96,
                            color: Colors.blue[50],
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
                              child: Text(
                                displayMessage,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    );
                  },
                  childCount: 1,
                ),
              ),
              if (state.state["textQuality"] == true)
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
                      },
                      childCount: 1,
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Center(
                      child: Text(
                        "Optimistic views:",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  childCount: 1,
                ),
              ),
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
                            labelText: 'your idea',
                          ),
                        ),
                      );
                    },
                    childCount: userConf.minAnswers,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final scenarioData = snapshot.data;

                          if (scenarioData == null ||
                              scenarioData.length < 4 ||
                              scenarioData[3] == null) {
                            setState(() {
                              message = "Nothing to save yet.";
                            });
                            return;
                          }

                          answersText.clear();
                          answers = 0;

                          for (final c in _controllers) {
                            if (c.text.isNotEmpty) {
                              answersText.add(c.text);
                              answers += 1;
                            }
                          }

                          await Stats.write(
                            db,
                            Stats(
                              time: DateTime.now().toString(),
                              input: scenarioData[0].toString(),
                              difficulty: scenarioData[1].toString(),
                              area: scenarioData[2].toString(),
                              count: answers,
                            ),
                          );

                          await saveAnswer(
                            client,
                            scenarioData[3]!,
                            answersText,
                            feedback,
                          );

                          for (final c in _controllers) {
                            c.clear();
                          }

                          if (!context.mounted) return;

                          if (timeToTrack) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return WellbeingDialog(
                                  client: client,
                                  deviceId: deviceId,
                                );
                              },
                            );
                          }

                          setState(() {
                            message = "Saved! Stay positive!:)";
                            state.update("textQuality", false);
                            feedback = null;
                          });
                        },
                        child: const Text('Go'),
                      ),
                    );
                  },
                  childCount: 1,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: SpeedDial(
        icon: Icons.account_circle,
        backgroundColor: Colors.lightBlue.shade100,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.fact_check),
            label: 'Usage',
            backgroundColor: Colors.lightBlue.shade300,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const UsageGuidanceDialog();
                },
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.build),
            label: 'Config',
            backgroundColor: Colors.lightBlue.shade200,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return ConfigDialog(config: userConf, state: state);
                },
              ).then((_) {
                setState(() {
                  if (state.state["firstTime"] == true) {
                    message = null;
                    _scenarioFuture = _fetchAndPersistNow();
                    state.update("firstTime", false);
                  }
                });
              });
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.refresh),
            label: 'New scenario',
            backgroundColor: Colors.lightBlue.shade100,
            onTap: () {
              setState(() {
                message = null;
                _scenarioFuture = _fetchAndPersistNow();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loginCheckFuture,
      builder: (context, loginSnapshot) {
        if (loginSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final bool loggedIn =
            !loginSnapshot.hasError && loginSnapshot.data == true;

        if (!loggedIn) {
          return _buildLogin();
        }

        // Important: scenario fetch starts here, after login is confirmed.
        _scenarioFuture ??= _computeScenarioAndMaybeFetch();

        return _buildHome(context);
      },
    );
  }
}
