import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicDivider extends StatefulWidget {
  final bool isFadeOut;
  final bool isForList;
  const OlukoNeumorphicDivider({this.isFadeOut = false, this.isForList = false}) : super();

  @override
  State<OlukoNeumorphicDivider> createState() => _OlukoNeumorphicDividerState();
}

class _OlukoNeumorphicDividerState extends State<OlukoNeumorphicDivider> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width - 80,
        height: 1.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isForList ? fadeOutListDivider : fadeOutColors,
            stops: [0.0, 0.5, 1],
          ),
        ));
  }

  List<Color> get fadeOutColors {
    return [
      widget.isFadeOut ? OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth : OlukoColors.grayColorFadeBottom,
      widget.isFadeOut ? OlukoColors.grayColor : OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
      widget.isFadeOut ? OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth : OlukoColors.grayColorFadeBottom
    ];
  }

  List<Color> get fadeOutListDivider {
    return [
      widget.isFadeOut ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.grayColorFadeBottom,
      widget.isFadeOut ? OlukoColors.grayColor.withOpacity(0.3) : OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
      widget.isFadeOut ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.grayColorFadeBottom
    ];
  }
}
