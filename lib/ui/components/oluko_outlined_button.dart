import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';

class OlukoOutlinedButton extends StatefulWidget {
  final Function() onPressed;
  final String title;

  OlukoOutlinedButton({this.title, this.onPressed});

  @override
  _State createState() => _State();
}

class _State extends State<OlukoOutlinedButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: BorderSide(color: OlukoColors.primary)),
          onPressed: () => widget.onPressed(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              widget.title,
              style: TextStyle(fontSize: 18),
            ),
          )),
    );
  }
}
