import 'package:flutter/material.dart';

class UsageGuidanceDialog extends StatefulWidget {
  const UsageGuidanceDialog({super.key});

  @override
  UsageGuidanceDialogState createState() => UsageGuidanceDialogState();
}

class UsageGuidanceDialogState extends State<UsageGuidanceDialog> {
  double? fontSize = 14;
  @override
  void initState() {
    super.initState();
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
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 5, 10),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text("Usage guidelines",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)))),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "1. Every day several different life scenarios are generated",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                  ))),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "2. Try to think of X (can be configured) positive or optimistic consequences or action for the shown scenario.",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                  ))),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "3. Fill in the forms with your answers and click 'go' button.",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                  ))),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "4. Only simple stats will be saved on the device: difficulty and life area of generated text, number answers, timestamp of the answers, model generated the text",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                  ))),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "5. If you do not like the text or want another one right away, click on user icon and then on 'New scenario' refresh button. You will have limited number of manual refresh attempts per day, since it takes a lot of resources to generate text",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                  ))),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "6. If you want to adjust any configuration of the app, click on user icon, then on 'Configuration' button. Endpoints control what models are being used. Closed is a privately hosted open source Mixtral7B model, all other providers are labeled by their actual name. No device/user information is sent to 3d parties platforms, only meta configuration for the scenario generation.",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                  ))),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: Text(
                                  "7. For more information: intended general use, research papers and external information links - click on user icon, then on 'Info' button.",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                  ))),
                        ]);
                  },
                  childCount: 1,
                ),
              ),
            ])));
  }
}
