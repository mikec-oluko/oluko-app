import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoBlurredButton extends StatefulWidget {
  final Widget childContent;
  const OlukoBlurredButton({this.childContent}) : super();

  @override
  State<OlukoBlurredButton> createState() => _OlukoBlurredButtonState();
}

class _OlukoBlurredButtonState extends State<OlukoBlurredButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 100,
        height: 100,
        color: Colors.transparent.withOpacity(0.3),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: widget.childContent),
      ),
    );
  }
}
