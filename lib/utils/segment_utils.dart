import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';

import 'oluko_localizations.dart';

class SegmentUtils {
  static List<Widget> getSegmentSummary(Segment segment, BuildContext context) {
    List<Widget> workoutWidgets = getWorkouts(segment, context);
    return [
          segment.rounds != null && segment.rounds > 1
              ? Text(
                  segment.rounds.toString() +
                      " " +
                      OlukoLocalizations.of(context).find('rounds'),
                  style: OlukoFonts.olukoBigFont(
                      customColor: OlukoColors.grayColor,
                      custoFontWeight: FontWeight.bold),
                )
              : SizedBox(),
          SizedBox(height: 12.0)
        ] +
        workoutWidgets;
  }

  static List<Widget> getWorkouts(Segment segment, BuildContext context) {
    List<Widget> workouts = [];
    String workoutString;
    segment.movements.forEach((MovementSubmodel movement) {
      if (movement.timerReps != null) {
        workoutString = movement.timerReps.toString() + 'x ' + movement.name;
      } else {
        workoutString =
            movement.timerWorkTime.toString() + 's ' + movement.name;
      }
      workouts.add(getTextWidget(workoutString));
    });
    return workouts;
  }

  static Widget getTextWidget(String text) {
    return Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: Text(
          text,
          style: OlukoFonts.olukoBigFont(
              custoFontWeight: FontWeight.w400,
              customColor: OlukoColors.grayColor),
        ));
  }
}
