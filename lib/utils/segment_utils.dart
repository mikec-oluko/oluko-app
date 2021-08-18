import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/models/timer_model.dart';

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

  ///Generates a list with all movement excercises and rests taking into account
  //sets and rounds. Returns a timer entry list consumible by the timer.
  static List<TimerEntry> getExercisesList(Segment segment) {
    List<TimerEntry> entries = [];
    for (var roundIndex = 0; roundIndex < segment.rounds; roundIndex++) {
      for (var movementIndex = 0;
          movementIndex < segment.movements.length;
          movementIndex++) {
        for (var setIndex = 0;
            setIndex < segment.movements[movementIndex].timerSets;
            setIndex++) {
          bool isTimedEntry =
              segment.movements[movementIndex].timerWorkTime != null;
          bool isLastMovement = movementIndex == segment.movements.length - 1;
          //Add work entry
          entries.add(TimerEntry(
              time: segment.movements[movementIndex].timerWorkTime,
              reps: segment.movements[movementIndex].timerReps,
              movement: segment.movements[movementIndex],
              setNumber: setIndex,
              roundNumber: roundIndex,
              label:
                  '${isTimedEntry ? segment.movements[movementIndex].timerWorkTime : segment.movements[movementIndex].timerReps} ${isTimedEntry ? 'Sec' : 'Reps'} ${segment.movements[movementIndex].name}',
              workState: WorkState.exercising));
          //Add rest entry
          entries.add(TimerEntry(
              time: isLastMovement
                  ? segment.roundBreakDuration
                  : segment.movements[movementIndex].timerRestTime,
              movement: segment.movements[movementIndex],
              setNumber: setIndex,
              roundNumber: roundIndex,
              label:
                  '${isLastMovement ? segment.roundBreakDuration : segment.movements[movementIndex].timerRestTime} Sec rest',
              workState: WorkState.repResting));
        }
      }
    }
    return entries;
  }
}
