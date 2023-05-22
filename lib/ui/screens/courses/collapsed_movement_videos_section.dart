import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/movement_videos_action_enum.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CollapsedMovementVideosSection extends StatefulWidget {
  final Widget action;

  CollapsedMovementVideosSection({this.action});

  @override
  _State createState() => _State();
}

class _State extends State<CollapsedMovementVideosSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [OlukoNeumorphismColors.initialGradientColorDark, OlukoNeumorphismColors.finalGradientColorDark],
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(children: [
          !OlukoNeumorphism.isNeumorphismDesign ? SizedBox.shrink() : SizedBox(height: 5),
          !OlukoNeumorphism.isNeumorphismDesign
              ? SizedBox.shrink()
              : Container(
                  width: 50,
                  child: Image.asset('assets/courses/horizontal_vector.png', scale: 2, color: OlukoColors.grayColor),
                ),
          SizedBox(height: 15),
          Row(children: [
            Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(OlukoLocalizations.get(context, 'movementVideos'), style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold))),
            SizedBox(width: 10),
            Image.asset(
              'assets/courses/person_running.png',
              scale: 4,
            ),
            Expanded(child: SizedBox()),
            widget.action
          ]),
          SizedBox(height: 10),
          OlukoNeumorphism.isNeumorphismDesign
              ? SizedBox.shrink()
              : Image.asset(
                  'assets/courses/horizontal_vector.png',
                  scale: 2,
                )
        ]));
  }
}
