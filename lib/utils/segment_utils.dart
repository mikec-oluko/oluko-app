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
  static List<TimerEntry> getExercisesList(
      Segment segment, BuildContext context) {
    if (hasRest(segment)) {
      return getIndividualExercisesList(segment);
    } else {
      return getJoinedExercisesList(segment, context);
    }
  }

  static List<TimerEntry> getIndividualExercisesList(Segment segment) {
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

          bool hasRest = segment.movements[movementIndex].timerRestTime != null;

          if (hasRest) {
            //Add rest entry
            entries.add(TimerEntry(
                time: segment.movements[movementIndex].timerRestTime,
                movement: segment.movements[movementIndex],
                setNumber: setIndex,
                roundNumber: roundIndex,
                label:
                    '${isLastMovement ? segment.roundBreakDuration : segment.movements[movementIndex].timerRestTime} Sec rest',
                workState: WorkState.repResting));
          }

          if (isLastMovement) {
            //Add round rest entry
            entries.add(TimerEntry(
                time: segment.roundBreakDuration,
                movement: segment.movements[movementIndex],
                setNumber: setIndex,
                roundNumber: roundIndex,
                label:
                    '${isLastMovement ? segment.roundBreakDuration : segment.movements[movementIndex].timerRestTime} Sec rest',
                workState: WorkState.repResting));
          }
        }
      }
    }
    return entries;
  }

  static List<TimerEntry> getJoinedExercisesList(
      Segment segment, BuildContext context) {
    List<TimerEntry> entries = [];
    for (var roundIndex = 0; roundIndex < segment.rounds; roundIndex++) {
        //Add work entry
        entries.add(TimerEntry(
            roundNumber: roundIndex,
            reps: segment.movements[0].timerReps,//Sets the timer by reps
            labels: getMovements(segment, context),
            workState: WorkState.exercising));
    }
    return entries;
  }

  static List<String> getMovements(Segment segment, BuildContext context) {
    List<String> movementStrings = [];
    segment.movements.forEach((MovementSubmodel movement) {
      if (movement.timerReps != null) {
        movementStrings
            .add(movement.timerReps.toString() + 'x ' + movement.name);
      } else {
        movementStrings
            .add(movement.timerWorkTime.toString() + 's ' + movement.name);
      }
      bool hasRest = movement.timerRestTime != null;

      if (hasRest) {
        movementStrings.add(movement.timerRestTime.toString() + 's rest');
      }
    });
    return movementStrings;
  }

  static bool hasRest(Segment segment) {
    bool hasRest = false;
    for (var movementIndex = 0;
        movementIndex < segment.movements.length;
        movementIndex++) {
      if (segment.movements[movementIndex].timerRestTime != null) {
        return true;
      }
    }
    return hasRest;
  }
}
