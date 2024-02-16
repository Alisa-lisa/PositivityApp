import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Dialog(
        child: Container(
            height: height * 0.9,
            width: width * 0.9,
            child: CustomScrollView(slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return const Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Center(
                          child: Text(
                              "1. Not a Mental Health App: \nPosicorn is not a mental health app. It is designed for lifestyle management and is not a substitute for professional mental health care."),
                        ));
                  },
                  childCount: 1,
                ),
              ),
            ])));
    // child: Column(children: [Text("Here comes disclaimer and links")]));
  }
}
