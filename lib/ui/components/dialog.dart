import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';

class DialogWidget extends StatefulWidget {
  final List<Widget> content;
  DialogWidget({this.content});
  @override
  _DialogWidgetState createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget> {
  @override
  Widget build(BuildContext context) {
    return _dialogContent(context, widget.content);
  }
}

_dialogContent(BuildContext context, List<Widget> content) {
  return Container(
    color: OlukoColors.black,
    child: ListView(
      shrinkWrap: true,
      children: content,
    ),
  );
}
