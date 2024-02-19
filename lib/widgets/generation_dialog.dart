import 'package:flutter/material.dart';

class GenDialog extends StatefulWidget {
  final int count;
  const GenDialog({required this.count, super.key});

  @override
  GenDialogState createState() => GenDialogState();
}

class GenDialogState extends State<GenDialog> {
  int get count => widget.count;
  @override
  void initState() {
    super.initState();
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
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
