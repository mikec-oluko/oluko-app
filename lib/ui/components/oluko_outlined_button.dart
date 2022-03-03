import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoOutlinedButton extends StatefulWidget {
  final Function() onPressed;
  final String title;
  final bool thinPadding;

  OlukoOutlinedButton({this.title, this.thinPadding = false, this.onPressed});

  @override
  _State createState() => _State();
}

class _State extends State<OlukoOutlinedButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: OutlinedButton(
      style: OutlinedButton.styleFrom(side: BorderSide(color: OlukoColors.primary)),
      onPressed: () => widget.onPressed(),
      child: widget.thinPadding
          ? Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 5.0, right: 5.0),
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 18, color: OlukoColors.primary),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                widget.title,
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary),
              ),
            ),
    ));
  }
}
