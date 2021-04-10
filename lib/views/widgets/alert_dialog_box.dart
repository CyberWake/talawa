import 'package:flutter/material.dart';
import 'package:talawa/generated/l10n.dart';

class AlertBox extends StatefulWidget {
  final String message;
  final Function function;
  AlertBox({this.message,this.function});
  @override
  _AlertBoxState createState() => _AlertBoxState();
}

class _AlertBoxState extends State<AlertBox> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).confirmation),
      content: Text(
          widget.message),
      actions: [
        ElevatedButton(
          child: Text(S.of(context).no),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text(S.of(context).yes),
          onPressed: () async {
            widget.function();
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
