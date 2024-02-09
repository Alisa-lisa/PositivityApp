import 'package:flutter/material.dart';

class GenDialog extends StatefulWidget {
  const GenDialog({super.key});

  @override
  GenDialogState createState() => GenDialogState();
}

class GenDialogState extends State<GenDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Dialog(
        child: Column(children: [Text("Here comes left resources")]));
  }
}
