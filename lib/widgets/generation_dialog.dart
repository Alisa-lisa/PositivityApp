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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Limited resources'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text(
                'Due to high cost of LLMs, number refreshes per day is limited'),
            Text('You have $count refresh attempts left.'),
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
