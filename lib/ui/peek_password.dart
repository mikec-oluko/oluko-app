import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PeekPassword extends StatefulWidget {
  final Function(bool) onPressed;

  PeekPassword({this.onPressed});

  @override
  _State createState() => _State();
}

class _State extends State<PeekPassword> {
  bool peekPassword = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        !peekPassword ? Icons.visibility : Icons.visibility_off,
        color: Theme.of(context).primaryColorDark,
      ),
      onPressed: () {
        peekPassword = !peekPassword;

        widget.onPressed(peekPassword);
      },
    );
  }
}
