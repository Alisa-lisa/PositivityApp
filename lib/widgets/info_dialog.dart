import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoDialog extends StatefulWidget {
  const InfoDialog({super.key});

  @override
  InfoDialogState createState() => InfoDialogState();
}

class InfoDialogState extends State<InfoDialog> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchUrl(String input) async {
    await launchUrl(Uri.parse(input));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Dialog(
        child: SizedBox(
            height: height * 0.9,
            width: width * 0.9,
            child: CustomScrollView(slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text("1. Not a Mental Health App.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "Posicorn is not a mental health app. It is designed for lifestyle management and is not a substitute for professional mental health care.",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text(
                                  "2. Not a Replacement for Mental Health Care Provider.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "Posicorn is not intended to replace the services of mental health care providers. Users should seek professional advice for mental health concerns.",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text("3. Stand Alone Tool from CBT.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "Posicorn  is a standalone tool inspired by cognitive-behavioral therapy (CBT). It is not a comprehensive CBT program and should not be considered as such.",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text("4. User Self-Evaluation.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "Users are responsible for evaluating whether Posicorn is suitable and effective for their individual needs. It is important to assess personal progress and discontinue use if necessary.",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text("5. No Responsibility for Misusage.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "The author of Posicorn is not responsible for any misuse or misinterpretation of the App. Users are urged to use the App responsibly and in accordance with its intended purpose.",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text("6. No Sensitive Data Collection.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "Posicorn does not collect sensitive personal data. User privacy is a priority, and no information that could compromise confidentiality is gathered.",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text("7. Tracking Data Storage",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "All tracking data generated by Posicorn is stored locally on the user's device only. No data is transmitted to external servers unless explicitly stated otherwise.",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text("8. Third-Party Data Providers.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "If Posicorn utilizes third-party data providers (data generators), these entities only receive non-user-specific requests. Individual user data remains confidential and is not shared with external parties.",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(5, 15, 5, 0),
                              child: Text(
                                  "By using Posicorn, you acknowledge and agree to the terms outlined in this disclaimer. If you do not agree with these terms, please refrain from using the App.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text("Useful links.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          Column(children: [
                            InkWell(
                                child: const Padding(
                                    padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                                    child: Text(
                                        "Posirtive Cognitive Behavioural Therapy (pCBT)",
                                        style: TextStyle(
                                          fontSize: 10,
                                        ))),
                                onTap: () {
                                  _launchUrl(
                                      "https://positivepsychology.com/positive-cbt/");
                                })
                          ])
                        ]);
                  },
                  childCount: 1,
                ),
              ),
            ])));
  }
}
