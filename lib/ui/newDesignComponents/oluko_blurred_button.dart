import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoBlurredButton extends StatefulWidget {
  final Widget childContent;
  final Color color;
  const OlukoBlurredButton({this.childContent, this.color}) : super();

  @override
  State<OlukoBlurredButton> createState() => _OlukoBlurredButtonState();
}

class _OlukoBlurredButtonState extends State<OlukoBlurredButton> {
  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? OlukoColors.black.withOpacity(0.3);
    final Widget childContent = widget.color != null ? widget.childContent : BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: widget.childContent);
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 100,
        height: 100,
        color: color,
        child: childContent,
      ),
    );
  }
}
