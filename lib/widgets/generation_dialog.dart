import 'package:flutter/material.dart';
import 'package:positivityapp/models/usage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenDialog extends StatefulWidget {
  final int count;
  final SharedPreferences prefs;
  const GenDialog({required this.count, required this.prefs, super.key});

  @override
  GenDialogState createState() => GenDialogState();
}

class GenDialogState extends State<GenDialog> {
  int get count => widget.count;
  SharedPreferences get prefs => widget.prefs;
  late UsageStats usage;

  @override
  void initState() {
    super.initState();
    usage = UsageStats().getUsage(prefs);
  }

  Widget getAlertText() {
    if (count == 0) {
      return const Text("You have used up all resources for today.");
    } else {
      return RichText(
          text: TextSpan(
              text: 'You have ',
              style: const TextStyle(fontSize: 12, color: Colors.black),
              children: <TextSpan>[
            TextSpan(
              text: '$count',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 20,
              ),
            ),
            const TextSpan(text: ' refresh attempts left.'),
          ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Limited resources'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text(
                'Due to high cost of LLMs, number refreshes per day is limited'),
            getAlertText(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            setState(() {
              usage.setUsage(prefs, null, count - 1);
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
