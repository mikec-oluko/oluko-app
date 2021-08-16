import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';

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
        Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              OlukoLocalizations.of(context).find('workouts') + ":",
              style: OlukoFonts.olukoSuperBigFont(
                  custoFontWeight: FontWeight.bold),
            )),
        segment.rounds != null && segment.rounds > 1
            ? Text(
                segment.rounds.toString() +
                    " " +
                    OlukoLocalizations.of(context).find('rounds') +
                    "\n",
                style: OlukoFonts.olukoMediumFont(),
              )
            : SizedBox(),
        ListView.builder(
            shrinkWrap: true,
            itemCount: workoutWidgets.length,
            itemBuilder: (context, index) {
              return workoutWidgets[index];
            })
      ],
    );
  }

  static List<Widget> getWorkouts(Segment segment, BuildContext context) {
    List<Widget> workouts = [];
    String workoutString;
    segment.movements.forEach((MovementSubmodel movement) {
      if (movement.timerSets != null && movement.timerSets > 1) {
        workoutString = movement.timerSets.toString() +
            " " +
            OlukoLocalizations.of(context).find('sets');

        workouts.add(getTextWidget(workoutString, false));
      }

      if (movement.timerReps != null) {
        workoutString =
            '• ' + movement.timerReps.toString() + ' rep ' + movement.name;
      } else {
        workoutString =
            '• ' + movement.timerWorkTime.toString() + ' sec ' + movement.name;
      }
      workouts.add(getTextWidget(workoutString, true));
      workoutString = '• ' + movement.timerRestTime.toString() + ' sec rest';
      workouts.add(getTextWidget(workoutString, true));
      workouts.add(getTextWidget(" ", true));
    });
    return workouts;
  }

  static Widget getTextWidget(String text, bool big) {
    TextStyle style;
    if (big) {
      style = OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal);
    } else {
      style = OlukoFonts.olukoMediumFont();
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
