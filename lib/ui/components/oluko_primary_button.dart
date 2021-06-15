import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';

class OlukoPrimaryButton extends StatefulWidget {
  final Function() onPressed;
  final String title;

  OlukoPrimaryButton({this.title, this.onPressed});

  @override
  _State createState() => _State();
}

class _State extends State<OlukoPrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: OlukoColors.primary,
              side: BorderSide(color: OlukoColors.primary)),
          onPressed: () => widget.onPressed(),
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 18),
              ))),
    );
  }
}
