import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/enums/timer_type_enum.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/timer_entry.dart';

import 'oluko_localizations.dart';

class SegmentUtils {
  static List<Widget> getSegmentSummary(Segment segment, BuildContext context) {
    List<Widget> workoutWidgets = getWorkouts(segment, context);
    return [
          getRoundTitle(segment, context, OlukoColors.grayColor),
          SizedBox(height: 12.0)
        ] +
        workoutWidgets;
  }

  static Widget getRoundTitle(
      Segment segment, BuildContext context, Color color) {
    if (segment.timerType == TimerTypeEnum.EMOM) {
      return getEMOMTitle(segment, context, color);
    } else if (segment.timerType == TimerTypeEnum.AMRAP) {
      return Text(
        segment.totalTime.toString() +
            " " +
            OlukoLocalizations.of(context).find('minutes') +
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
        bool hasSets = segment.movements[movementIndex].timerSets != null;
        int cantSets = hasSets ? segment.movements[movementIndex].timerSets : 1;
        for (var setIndex = 0; setIndex < cantSets; setIndex++) {
          bool isTimedEntry =
              segment.movements[movementIndex].timerWorkTime != null;
          bool isLastMovement = movementIndex == segment.movements.length - 1;
          //Add work entry
          entries.add(TimerEntry(
              time: segment.movements[movementIndex].timerWorkTime,
              reps: segment.movements[movementIndex].timerReps,
              movement: segment.movements[movementIndex],
              setNumber: hasSets ? setIndex + 1 : null,
              roundNumber: roundIndex + 1,
              counter: segment.movements[movementIndex].counter,
              label:
                  '${isTimedEntry ? segment.movements[movementIndex].timerWorkTime : segment.movements[movementIndex].timerReps}${isTimedEntry ? 's' : 'x'} ${segment.movements[movementIndex].name}',
              workState: WorkState.exercising));

          bool hasRest = segment.movements[movementIndex].timerRestTime != null;

          if (hasRest) {
            //Add rest entry
            entries.add(TimerEntry(
                time: segment.movements[movementIndex].timerRestTime,
                movement: segment.movements[movementIndex],
                setNumber: hasSets ? setIndex + 1 : null,
                roundNumber: roundIndex + 1,
                label:
                    '${segment.movements[movementIndex].timerRestTime}s rest',
                workState: WorkState.resting));
          }

          if (isLastMovement && segment.roundBreakDuration != null) {
            //Add round rest entry
            entries.add(TimerEntry(
                time: segment.roundBreakDuration,
                movement: segment.movements[movementIndex],
                setNumber: hasSets ? setIndex + 1 : null,
                roundNumber: roundIndex + 1,
                label:
                    '${isLastMovement ? segment.roundBreakDuration : segment.movements[movementIndex].timerRestTime}s rest',
                workState: WorkState.resting));
          }
        }
      }
    }
    return entries;
  }

  static List<TimerEntry> getJoinedExercisesList(
      Segment segment, BuildContext context) {
    List<TimerEntry> entries = [];
    bool hasRounds = segment.rounds != null;
    int cantRounds = hasRounds ? segment.rounds : 1;
    for (var roundIndex = 0; roundIndex < cantRounds; roundIndex++) {
      //Add work entry
      entries.add(TimerEntry(
          roundNumber: hasRounds ? roundIndex + 1 : null,
          reps: segment.timerType == TimerTypeEnum.combined
              ? segment.movements[0].timerReps
              : null,
          time: getJoinedTime(segment),
          labels: getMovements(segment, context),
          workState: WorkState.exercising));
    }
    return entries;
  }

  static int getJoinedTime(Segment segment) {
    if (segment.timerType == TimerTypeEnum.EMOM) {
      return (segment.totalTime ~/ segment.rounds).toInt();
    } else if (segment.timerType == TimerTypeEnum.AMRAP) {
      return segment.totalTime;
    } else {
      return null;
    }
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
    if (segment.roundBreakDuration != null) {
      return true;
    }
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
