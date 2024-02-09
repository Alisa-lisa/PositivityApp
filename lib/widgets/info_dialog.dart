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
    return const Dialog(
        child: Column(children: [Text("Here comes disclaimer and links")]));
  }
}
