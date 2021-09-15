import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/timer_entry.dart';

import 'oluko_localizations.dart';

class SegmentUtils {
  static List<Widget> getSegmentSummary(Segment segment, BuildContext context) {
    List<Widget> workoutWidgets = getWorkouts(segment);
    return [
          getRoundTitle(segment, context, OlukoColors.grayColor),
          SizedBox(height: 12.0)
        ] +
        workoutWidgets;
  }

  static Widget getRoundTitle(
      Segment segment, BuildContext context, Color color) {
    if (segment.sections.length == 1 && segment.sections[0].totalTime == null) {
      return getEMOMTitle(segment, context, color);
    } else if (segment.rounds == null) {
      return Text(
        segment.totalTime.toString() +
            " " +
            OlukoLocalizations.of(context).find('seconds').toLowerCase() +
            " " +
            "AMRAP",
        style: OlukoFonts.olukoBigFont(
            customColor: color, custoFontWeight: FontWeight.bold),
      );
    } else {
      return segment.rounds > 1
          ? Text(
              segment.rounds.toString() +
                  " " +
                  OlukoLocalizations.of(context).find('rounds'),
              style: OlukoFonts.olukoBigFont(
                  customColor: color, custoFontWeight: FontWeight.bold),
            )
          : SizedBox();
    }
  }

  static Widget getEMOMTitle(
      Segment segment, BuildContext context, Color color) {
    return Text(
      "EMOM: " +
          segment.rounds.toString() +
          " " +
          OlukoLocalizations.of(context).find('rounds') +
          " " +
          OlukoLocalizations.of(context).find('in') +
          " " +
          segment.totalTime.toString() +
          " " +
          OlukoLocalizations.of(context).find('minutes'),
      style: OlukoFonts.olukoBigFont(
          customColor: color, custoFontWeight: FontWeight.bold),
    );
  }

  static List<Widget> getWorkouts(Segment segment) {
    List<Widget> workouts = [];
    for (var sectionIndex = 0;
        sectionIndex < segment.sections.length;
        sectionIndex++) {
      for (var movementIndex = 0;
          movementIndex < segment.sections[sectionIndex].movements.length;
          movementIndex++) {
        MovementSubmodel movement =
            segment.sections[sectionIndex].movements[movementIndex];
        workouts.add(getTextWidget(getLabel(movement)));
      }
    }
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

  ///Generates a list with all movement excercises and rests taking into account
  //sets and rounds. Returns a timer entry list consumible by the timer.
  static List<TimerEntry> getExercisesList(Segment segment) {
    List<TimerEntry> entries = [];
    for (var roundIndex = 0; roundIndex < segment.rounds; roundIndex++) {
      for (var sectionIndex = 0;
          sectionIndex < segment.sections.length;
          sectionIndex++) {
        bool hasMultipleMovements =
            segment.sections[sectionIndex].movements.length > 1;
        if (hasMultipleMovements) {
          for (var movementIndex = 0;
              movementIndex < segment.sections[sectionIndex].movements.length;
              movementIndex++) {
            MovementSubmodel movementSubmodel =
                segment.sections[sectionIndex].movements[movementIndex];
            entries.add(TimerEntry(
                movement: movementSubmodel,
                parameter: movementSubmodel.parameter,
                quantity: movementSubmodel.quantity,
                round: roundIndex + 1,
                counter: movementSubmodel.counter,
                labels: getLabels(segment.sections[sectionIndex].movements)));
          }
        } else {
          MovementSubmodel movementSubmodel =
              segment.sections[sectionIndex].movements[0];
          entries.add(TimerEntry(
              movement: movementSubmodel,
              parameter: movementSubmodel.parameter,
              quantity: movementSubmodel.quantity,
              round: roundIndex + 1,
              counter: movementSubmodel.counter,
              labels: [getLabel(movementSubmodel)]));
        }
      }
    }
    return entries;
  }

  static String getLabel(MovementSubmodel movement) {
    String label = movement.quantity.toString();
    switch (movement.parameter) {
      case ParameterEnum.duration:
        label += "s";
        break;
      case ParameterEnum.reps:
        label += "x";
        break;
    }
    label += " " + movement.name;
    return label;
  }

  static List<String> getLabels(List<MovementSubmodel> movements) {
    List<String> movementStrings = [];
    movements.forEach((movement) {
      movementStrings.add(getLabel(movement));
    });
    return movementStrings;
  }

  static List<Widget> getJoinedLabel(List<String> labels) {
    List<Widget> labelWidgets = [];
    labels.forEach((label) {
      labelWidgets.add(Text(label,
          style: TextStyle(
              fontSize: 20,
              color: OlukoColors.white,
              fontWeight: FontWeight.w300)));
      labelWidgets.add(Divider(
        height: 10,
        color: OlukoColors.divider,
        thickness: 0,
        indent: 0,
        endIndent: 0,
      ));
    });
    return labelWidgets;
  }

  static Column workouts(Segment segment, BuildContext context) {
    List<Widget> workoutWidgets = getWorkouts(segment);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          [getRoundTitle(segment, context, OlukoColors.white)] + workoutWidgets,
    );
  }
}
