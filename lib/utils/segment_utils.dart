import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/personal_record_param.dart';
import 'package:oluko_app/models/enums/segment_type_enum.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/ui/newDesignComponents/movement_items_bubbles_neumorphic.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

import 'oluko_localizations.dart';

class SegmentUtils {
  static List<Widget> getSegmentSummary(Segment segment, BuildContext context, Color color) {
    List<String> workoutWidgets = getWorkouts(segment);
    return <Widget>[
          Text(
            getRoundTitle(segment, context),
            style: OlukoNeumorphism.isNeumorphismDesign
                ? OlukoFonts.olukoSuperBigFont(customColor: color, customFontWeight: FontWeight.bold)
                : OlukoFonts.olukoBigFont(customColor: color, customFontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.0)
        ] +
        workoutWidgets.map((e) => getTextWidget(e, color))?.toList();
  }

  static List<Widget> getSegmentSummaryforNeumorphic(Segment segment, BuildContext context, Color color,
      {bool roundTitle = true, bool restTime = true, List<Movement> movements = const [], bool viewDetailsScreen = false}) {
    List<Widget> workoutWidgets = getWorkoutsforNeumorphic(segment, color,
        restTime: restTime, movements: movements, context: context, viewDetailsScreen: viewDetailsScreen);
    if (roundTitle) {
      return [
            Text(
              getRoundTitle(segment, context),
              style: OlukoNeumorphism.isNeumorphismDesign
                  ? OlukoFonts.olukoSuperBigFont(customColor: color, customFontWeight: FontWeight.bold)
                  : OlukoFonts.olukoBigFont(customColor: color, customFontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0)
          ] +
          workoutWidgets;
    } else {
      return workoutWidgets;
    }
  }

  static bool isEMOM(Segment segment) {
    return segment.sections.length == 1 && segment.type == SegmentTypeEnum.RoundsAndDuration;
  }

  static bool isAMRAP(Segment segment) {
    return segment.type == SegmentTypeEnum.Duration;
  }

  static String getRoundTitle(Segment segment, BuildContext context) {
    if (isEMOM(segment)) {
      return getEMOMTitle(segment, context);
    } else if (isAMRAP(segment)) {
      return '${segment.totalTime} ${OlukoLocalizations.get(context, 'seconds').toLowerCase()} AMRAP';
    } else {
      return segment.rounds > 1 ? '${segment.rounds} ${OlukoLocalizations.get(context, 'rounds')}' : '';
    }
  }

  static bool hasTitle(Segment segment) {
    if (isEMOM(segment)) {
      return true;
    } else if (isAMRAP(segment)) {
      return true;
    } else {
      return segment.rounds > 1 ? true : false;
    }
  }

  static String getEMOMTitle(Segment segment, BuildContext context) {
    return 'EMOM: ${segment.rounds} ${OlukoLocalizations.get(context, 'rounds')} ${OlukoLocalizations.get(context, 'in')} ${segment.totalTime} ${OlukoLocalizations.get(context, 'seconds')}';
  }

  static List<String> getWorkouts(Segment segment) {
    List<String> workouts = [];
    if (segment.sections != null) {
      for (var sectionIndex = 0; sectionIndex < segment.sections.length; sectionIndex++) {
        for (var movementIndex = 0; movementIndex < segment.sections[sectionIndex].movements.length; movementIndex++) {
          MovementSubmodel movement = segment.sections[sectionIndex].movements[movementIndex];
          workouts.add(getLabel(movement));
        }
      }
    }

    return workouts;
  }

  static List<Widget> getWorkoutsforNeumorphic(Segment segment, Color color,
      {bool restTime = true, List<Movement> movements = const [], BuildContext context, bool viewDetailsScreen = false}) {
    List<Widget> workouts = [];
    if (segment.sections != null) {
      for (var sectionIndex = 0; sectionIndex < segment.sections.length; sectionIndex++) {
        for (var movementIndex = 0; movementIndex < segment.sections[sectionIndex].movements.length; movementIndex++) {
          MovementSubmodel movement = segment.sections[sectionIndex].movements[movementIndex];
          Movement movementWithImage;
          if (movements.isNotEmpty)
            for (var movementsIndex = 0; movementsIndex < movements.length; movementsIndex++) {
              if (movement.id == movements[movementsIndex].id) movementWithImage = movements[movementsIndex];
            }
          if (restTime)
            workouts.add(getTextWidget(getLabel(movement), color));
          else if (movement.name != 'Rest time' && movement.name != 'Rest') {
            workouts.add(Row(
              children: [
                MovementItemBubblesNeumorphic(
                  content: movements,
                  viewDetailsScreen: true,
                  movement: movementWithImage, //movementWithImage=null? overflow error
                  width: ScreenUtils.width(context) / 4,
                  bubbleName: false,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(width: ScreenUtils.width(context) * 0.57, child: getTextWidget(getLabel(movement), color)),
                ),
              ],
            ));
          }
          ;
        }
      }
    }

    return workouts;
  }

  static Widget getTextWidget(String text, Color color) {
    return Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: Text(
          text,
          style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: color),
        ));
  }

  ///Generates a list with all movement excercises and rests taking into account
  //sets and rounds. Returns a timer entry list consumible by the timer.
  static List<TimerEntry> getExercisesList(Segment segment) {
    List<TimerEntry> entries = [];
    entries.add(getInitialEntry(segment));
    if (isAMRAP(segment)) {
      MovementSubmodel movementSubmodel = segment.sections[0].movements[0];
      entries.add(TimerEntry(
          movement: movementSubmodel,
          parameter: ParameterEnum.duration,
          value: segment.totalTime,
          round: null,
          counter: CounterEnum.none,
          stopwatch: segment.sections[0].stopwatch,
          labels: getLabels(segment.sections[0].movements)));
    } else {
      for (var roundIndex = 0; roundIndex < segment.rounds; roundIndex++) {
        if (isEMOM(segment)) {
          MovementSubmodel movementSubmodel = segment.sections[0].movements[0];
          entries.add(TimerEntry(
              movement: movementSubmodel,
              parameter: ParameterEnum.duration,
              value: (segment.totalTime / segment.rounds).toInt(),
              round: roundIndex,
              counter: CounterEnum.none,
              stopwatch: segment.sections[0].stopwatch,
              labels: getLabels(segment.sections[0].movements)));
        } else {
          for (var sectionIndex = 0; sectionIndex < segment.sections.length; sectionIndex++) {
            bool hasMultipleMovements = segment.sections[sectionIndex].movements.length > 1;
            if (hasMultipleMovements) {
              MovementSubmodel movementSubmodel = segment.sections[sectionIndex].movements[0];
              entries.add(TimerEntry(
                  movement: movementSubmodel,
                  parameter: movementSubmodel.parameter == null ? ParameterEnum.reps : movementSubmodel.parameter,
                  value: movementSubmodel.value == null ? 5 : movementSubmodel.value,
                  round: roundIndex,
                  sectionIndex: sectionIndex,
                  counter: movementSubmodel.counter,
                  stopwatch: segment.sections[sectionIndex].stopwatch,
                  labels: getLabels(segment.sections[sectionIndex].movements)));
            } else {
              MovementSubmodel movementSubmodel = segment.sections[sectionIndex].movements[0];
              entries.add(TimerEntry(
                  movement: movementSubmodel,
                  parameter: movementSubmodel.parameter == null ? ParameterEnum.reps : movementSubmodel.parameter,
                  value: movementSubmodel.value == null ? 5 : movementSubmodel.value,
                  round: roundIndex,
                  sectionIndex: sectionIndex,
                  counter: movementSubmodel.counter,
                  stopwatch: segment.sections[sectionIndex].stopwatch,
                  labels: [getLabel(movementSubmodel)]));
            }
          }
        }
      }
    }
    if (entries[entries.length - 1].movement.isRestTime && entries[entries.length - 1].movement.counter == CounterEnum.none) {
      entries.removeAt(entries.length - 1);
    }
    return entries;
  }

  static String getLabel(MovementSubmodel movement) {
    String label = movement.value == null ? '5' : movement.value.toString();
    String parameter;
    if (movement.parameter != null) {
      switch (movement.parameter) {
        case ParameterEnum.duration:
          label = TimeConverter.durationToString(Duration(seconds: movement.value));
          //label += 's';
          parameter = 's';
          break;
        case ParameterEnum.reps:
          label += 'x';
          parameter = 'x';
          break;
        case ParameterEnum.distance:
          label += 'm';
          parameter = 'm';
          break;
      }
    } else {
      label += 'x';
    }

    label += ' ${movement.name}';
    if (movement.isBothSide) {
      int qty = (movement.value / 2).toInt();
      String text = '$qty$parameter';
      label += ' ($text/$text)';
    }
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
      labelWidgets.add(
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: OlukoColors.white, fontWeight: FontWeight.w300)));
      labelWidgets.add(OlukoNeumorphism.isNeumorphismDesign
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: OlukoNeumorphicDivider(
                isForList: true,
                isFadeOut: true,
              ),
            )
          : Divider(
              height: 10,
              color: OlukoColors.divider,
              thickness: 0,
              indent: 0,
              endIndent: 0,
            ));
    });
    return labelWidgets;
  }

  static Column workouts(Segment segment, BuildContext context, Color color) {
    final List<String> workoutWidgets = getWorkouts(segment);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: titleList(segment, context) + workoutWidgets.map((e) => getTextWidget(e, color))?.toList());
  }

  static List<Widget> titleList(Segment segment, BuildContext context) {
    return hasTitle(segment)
        ? [
            Text(
              getRoundTitle(segment, context),
              style: OlukoNeumorphism.isNeumorphismDesign
                  ? OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.bold)
                  : OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.bold),
            )
          ]
        : [];
  }

  static CoachRequest getSegmentCoachRequest(
      List<CoachRequest> coachRequests, String segmentId, String courseEnrollmentId, String classId) {
    for (var i = 0; i < coachRequests.length; i++) {
      if (coachRequests[i].segmentId == segmentId &&
          coachRequests[i].courseEnrollmentId == courseEnrollmentId &&
          coachRequests[i].classId == classId) {
        return coachRequests[i];
      }
    }
    return null;
  }

  static TimerEntry getInitialEntry(Segment segment) {
    return TimerEntry(
        movement: segment.sections[0].movements[0],
        parameter: ParameterEnum.duration,
        value: segment.initialTimer,
        round: 0,
        sectionIndex: 0,
        counter: CounterEnum.none,
        stopwatch: false,
        labels: getLabels(segment.sections[0].movements),
        isInitialTimer: true);
  }

  static PersonalRecordParam getPersonalRecordParam(CounterEnum counter, Segment segment) {
    PersonalRecordParam parameter;
    if (isAMRAP(segment)) {
      parameter = PersonalRecordParam.rounds;
    } else {
      switch (counter) {
        case CounterEnum.distance:
          parameter = PersonalRecordParam.distance;
          break;
        case CounterEnum.weight:
          parameter = PersonalRecordParam.weight;
          break;
        case CounterEnum.reps:
          parameter = PersonalRecordParam.reps;
          break;
        case CounterEnum.none:
          parameter = PersonalRecordParam.duration;
          break;
      }
    }
    return parameter;
  }

  static String getParamLabel(PersonalRecordParam parameter) {
    String label = "";
    switch (parameter) {
      case PersonalRecordParam.duration:
        label = 's';
        break;
      case PersonalRecordParam.reps:
        label = 'reps';
        break;
      case PersonalRecordParam.distance:
        label = 'm';
        break;
      case PersonalRecordParam.rounds:
        label = 'rounds';
        break;
      case PersonalRecordParam.weight:
        label = 'lbs';
        break;
    }
    return label;
  }

  static String getCounterInputLabel(CounterEnum counter) {
    switch (counter) {
      case CounterEnum.reps:
        return 'reps';
      case CounterEnum.distance:
        return 'm';
      case CounterEnum.weight:
        return 'lbs';
      default:
        return '';
    }
  }
}
