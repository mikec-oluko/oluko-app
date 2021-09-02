import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/utils/segment_utils.dart';

import 'oluko_localizations.dart';

class MovementUtils {
  static Text movementTitle(String title) {
    return Text(
      title,
      style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
    );
  }

  static description(String description, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              OlukoLocalizations.of(context).find('description') + ":",
              style: OlukoFonts.olukoSuperBigFont(
                  custoFontWeight: FontWeight.bold),
            )),
        Text(
          description,
          style: OlukoFonts.olukoBigFont(
              custoFontWeight: FontWeight.normal,
              customColor: OlukoColors.white),
        ),
      ],
    );
  }

  static Column workout(Segment segment, BuildContext context) {
    List<Widget> workoutWidgets = getWorkouts(segment, context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            segment.rounds != null && segment.rounds > 1
                ? SegmentUtils.getRoundTitle(
                    segment, context, OlukoColors.white)
                : SizedBox(),
          ] +
          workoutWidgets,
    );
  }

  static List<Widget> getWorkouts(Segment segment, BuildContext context) {
    List<Widget> workouts = [
      SizedBox(
        height: 10,
      )
    ];
    String workoutString;
    segment.movements.forEach((MovementSubmodel movement) {
      if (movement.timerSets != null && movement.timerSets > 1) {
        workoutString = movement.timerSets.toString() +
            " " +
            OlukoLocalizations.of(context).find('sets');
        workouts.add(Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: getTextWidget(workoutString, false)));
      }

      if (movement.timerReps != null) {
        workoutString = movement.timerReps.toString() + 'x ' + movement.name;
      } else {
        workoutString =
            movement.timerWorkTime.toString() + 's ' + movement.name;
      }
      workouts.add(getTextWidget(workoutString, true));

      bool hasRest = movement.timerRestTime != null;

      if (hasRest) {
        workoutString = movement.timerRestTime.toString() + 's rest';
        workouts.add(getTextWidget(workoutString, true));
      }
      if (hasRest) {
        workouts.add(getTextWidget(" ", true));
      }
    });
    if (segment.roundBreakDuration != null) {
      workoutString = segment.roundBreakDuration.toString() + 's rest';
      workouts.add(getTextWidget(workoutString, true));
    }
    return workouts;
  }

  static Widget getTextWidget(String text, bool big) {
    TextStyle style;
    if (big) {
      style = OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400);
    } else {
      style = OlukoFonts.olukoBigFont();
    }
    return Text(
      text,
      style: style,
    );
  }

  static Column labelWithTitle(String title, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: OlukoFonts.olukoBigFont(),
        )
      ],
    );
  }
}
