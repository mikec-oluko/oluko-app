import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class DialogWidget extends StatelessWidget {
  const DialogWidget() : super();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: OlukoColors.black,
          child: _dialogContent(context),
        ));
  }
}

Widget _dialogContent(context) {
  showModalBottomSheet(context: context, builder: (BuildContext _) {});
}
