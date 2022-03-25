import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/animation_bloc.dart';
import 'package:oluko_app/blocs/keyboard/keyboard_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/custom_keyboard.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/modal_segment_movements.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_watch_app_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:wakelock/wakelock.dart';

enum WorkoutType { segment, segmentWithRecording }

class SegmentClocksUtils {
  static List<Widget> getScoresByRound(
      BuildContext context, List<TimerEntry> timerEntries, int timerTaskIndex, int totalScore, List<String> scores) {
    List<String> lbls = counterText(
        context,
        timerEntries[timerEntries[timerTaskIndex - 1].movement.isRestTime ? timerTaskIndex : timerTaskIndex - 1].counter,
        timerEntries[timerTaskIndex - 1].movement.name);
    final bool isCounterByReps = timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps;
    final List<Widget> widgets = [];
    String totalText = '${OlukoLocalizations.get(context, 'total')}: $totalScore ';
    if (!lbls.isEmpty) {
      totalText += lbls[1];
    }

    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(totalText, style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.primary)),
        ],
      ),
    );

    widgets.add(const SizedBox(height: 15));
    for (int i = 0; i < scores.length; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${OlukoLocalizations.get(context, 'round')} ${i + 1}',
                style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.white),
              ),
              SizedBox(
                width: ScreenUtils.width(context) * 0.5,
                child: Text(
                  scores[i],
                  textAlign: TextAlign.end,
                  style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400, customColor: OlukoColors.white),
                ),
              )
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  static List<String> counterText(BuildContext context, CounterEnum counter, String movementName) {
    List<String> counterText = [];
    switch (counter) {
      case CounterEnum.reps:
        counterText.add(OlukoLocalizations.get(context, 'enterScore'));
        counterText.add(movementName);
        break;
      case CounterEnum.distance:
        counterText.add(OlukoLocalizations.get(context, 'enterScore'));
        counterText.add(OlukoLocalizations.get(context, 'meters'));
        break;
      case CounterEnum.weight:
        counterText.add(OlukoLocalizations.get(context, 'enterWeight'));
        counterText.add(OlukoLocalizations.get(context, 'lbs'));
        break;
      default:
    }
    return counterText;
  }

  static Widget getKeyboard(BuildContext context, bool keyboardVisibilty) {
    const boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff2b2f35), Color(0xff16171b)],
      ),
    );
    return SizedBox(
      width: ScreenUtils.width(context),
      child: Visibility(
        visible: keyboardVisibilty,
        child: CustomKeyboard(
          boxDecoration: boxDecoration,
        ),
      ),
    );
  }

  static Widget nextTaskWidget(String nextTask, bool keyboardVisibilty) {
    return Visibility(
      visible: !keyboardVisibilty,
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.transparent],
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        blendMode: BlendMode.dstIn,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            nextTask,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, color: Color.fromRGBO(255, 255, 255, 0.25), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static Future<bool> onWillPop(BuildContext contextWBloc, bool isRecording) async {
    return (await showDialog(
          context: contextWBloc,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: TitleBody(OlukoLocalizations.get(context, 'exitConfirmationTitle')),
            content: Text(
              isRecording
                  ? OlukoLocalizations.get(context, 'goBackConfirmationWithRecording')
                  : OlukoLocalizations.get(context, 'goBackConfirmationWithoutRecording'),
              style: OlukoFonts.olukoBigFont(),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  OlukoLocalizations.get(context, 'no'),
                ),
              ),
              BlocBuilder<KeyboardBloc, KeyboardState>(
                bloc: BlocProvider.of<KeyboardBloc>(contextWBloc),
                builder: (context, state) {
                  return TextButton(
                    onPressed: () {
                      BlocProvider.of<AnimationBloc>(context).playPauseAnimation();
                      Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.segmentDetail]));
                      BlocProvider.of<KeyboardBloc>(contextWBloc).add(HideKeyboard());
                    },
                    child: Text(
                      OlukoLocalizations.get(context, 'yes'),
                    ),
                  );
                },
              ),
            ],
          ),
        )) ??
        false;
  }

  static PreferredSizeWidget getAppBar(BuildContext context, Widget topBarIcon, bool segmentWithRecording) {
    PreferredSizeWidget appBarToUse;
    if (OlukoNeumorphism.isNeumorphismDesign) {
      appBarToUse = OlukoWatchAppBar(
        onPressed: () => onWillPop(context, segmentWithRecording),
        actions: [topBarIcon, audioIcon()],
      );
    } else {
      appBarToUse = OlukoAppBar(
        showActions: true,
        showDivider: false,
        title: ' ',
        showTitle: false,
        showBackButton: true,
        actions: [topBarIcon, audioIcon()],
      );
    }
    return appBarToUse;
  }

  static Widget audioIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Image.asset(
        'assets/courses/audio_icon.png',
        scale: 4,
      ),
    );
  }

  static Widget recordingTaskSection(bool keyboardVisibilty, BuildContext context, List<TimerEntry> timerEntries, int timerTaskIndex) {
    final bool hasMultipleLabels = timerEntries[timerTaskIndex].labels.length > 1;
    if (hasMultipleLabels) {
      final List<Widget> items = SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels);
      return SizedBox(
        width: 200,
        child: OlukoNeumorphicSecondaryButton(
          thinPadding: true,
          isExpanded: false,
          icon: Icon(
            //Secondary button allows only text or only icon
            Icons.search,
            color: OlukoColors.primary,
          ),
          onPressed: () => MovementsModal.modalContent(context: context, content: items),
          title: OlukoLocalizations.get(context, 'movements'),
        ),
      );
    } else {
      final String currentTask = timerEntries[timerTaskIndex].labels[0];
      final String nextTask = timerTaskIndex < timerEntries.length - 1 ? timerEntries[timerTaskIndex + 1].labels[0] : '';
      return SizedBox(
        width: ScreenUtils.width(context),
        child: Padding(
          padding: EdgeInsets.only(
            top: 7,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: ScreenUtils.width(context) * 0.7, child: currentTaskWidget(keyboardVisibilty, currentTask, true)),
              Positioned(
                left: ScreenUtils.width(context) - 70,
                child: Text(
                  nextTask,
                  style: const TextStyle(fontSize: 20, color: OlukoColors.grayColorSemiTransparent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  static Widget currentTaskWidget(bool keyboardVisibilty, String currentTask, [bool smaller = false]) {
    return Visibility(
      visible: !keyboardVisibilty,
      child: Padding(
        padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(horizontal: 20) : EdgeInsets.zero,
        child: Text(
          currentTask,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: smaller ? 20 : 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget uploadingIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Text(
              'Uploading',
              style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.w400),
              textAlign: TextAlign.start,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.upload, color: Colors.white)
          ],
        ),
      ),
    );
  }

  static Widget cameraSection(
      BuildContext context, bool isWorkStatePaused, bool isCameraReady, CameraController cameraController, Widget pauseButton) {
    return isWorkStatePaused
        ? const SizedBox()
        : SizedBox(
            height: ScreenUtils.height(context) / 2,
            width: ScreenUtils.width(context),
            child: Stack(
              children: [
                if (!isCameraReady)
                  Container()
                else
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/courses/camera_background.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(child: AspectRatio(aspectRatio: 3.0 / 4.0, child: CameraPreview(cameraController))),
                  ),
                Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.all(20.0), child: pauseButton)),
              ],
            ),
          );
  }

  static Widget pauseButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/courses/oval.png',
          scale: 4,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Image.asset(
            'assets/courses/center_oval.png',
            scale: 4,
          ),
        ),
        Image.asset(
          'assets/courses/pause_button.png',
          scale: 4,
        ),
      ],
    );
  }

  static double getWatchPadding(WorkState workState, bool usePulseAnimation) {
    double paddingValue = 0;
    if (OlukoNeumorphism.isNeumorphismDesign) {
      if (workState == WorkState.resting) {
        if (!usePulseAnimation) {
          paddingValue = 40.0;
        } else {
          paddingValue = 20.0;
        }
      } else {
        paddingValue = 30.0;
      }
    }
    return paddingValue;
  }

  static Widget finishedButtonsWithRecording(BuildContext context, Function() shareDoneAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OlukoPrimaryButton(
            title: OlukoLocalizations.get(context, 'done'),
            thinPadding: true,
            onPressed: () {
              shareDoneAction();
            },
          ),
        ],
      ),
    );
  }

  static Widget finishedButtonsWithoutRecording(
      BuildContext context, Function() goToClass, Function() nextSegmentAction, List<Segment> segments, int segmentIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OlukoOutlinedButton(
            title: OlukoLocalizations.get(context, 'goToClass'),
            thinPadding: true,
            onPressed: () {
              goToClass();
            },
          ),
          const SizedBox(
            width: 15,
          ),
          OlukoPrimaryButton(
            title: segmentIndex == segments.length - 1
                ? OlukoLocalizations.get(context, 'done')
                : OlukoLocalizations.get(context, 'nextSegment'),
            thinPadding: true,
            onPressed: () {
              nextSegmentAction();
            },
          ),
        ],
      ),
    );
  }

  static Widget showButtonsWhenFinished(WorkoutType workoutType, bool shareDone, BuildContext context, Function() shareDoneAction,
      Function() goToClass, Function() nextSegmentAction, List<Segment> segments, int segmentIndex) {
    return !OlukoNeumorphism.isNeumorphismDesign
        ? showFinishedButtons(workoutType, shareDone, context, shareDoneAction, goToClass, nextSegmentAction, segments, segmentIndex)
        : neumorphicFinishedButtons(workoutType, shareDone, context, shareDoneAction, goToClass, nextSegmentAction, segments, segmentIndex);
  }

  static Widget showFinishedButtons(WorkoutType workoutType, bool shareDone, BuildContext context, Function() shareDoneAction,
      Function() goToClass, Function() nextSegmentAction, List<Segment> segments, int segmentIndex) {
    if (workoutType == WorkoutType.segmentWithRecording && !shareDone) {
      return finishedButtonsWithRecording(context, shareDoneAction);
    } else {
      return finishedButtonsWithoutRecording(context, goToClass, nextSegmentAction, segments, segmentIndex);
    }
  }

  static Widget neumorphicFinishedButtons(WorkoutType workoutType, bool shareDone, BuildContext context, Function() shareDoneAction,
      Function() goToClass, Function() nextSegmentAction, List<Segment> segments, int segmentIndex) {
    Wakelock.disable();
    if (workoutType == WorkoutType.segmentWithRecording && !shareDone) {
      return neumporphicFinishedButtonsWithRecording(context, shareDoneAction);
    } else {
      return neumorphicFinishedButtonsWithoutRecording(context, goToClass, nextSegmentAction, segments, segmentIndex);
    }
  }

  static Widget neumorphicFinishedButtonsWithoutRecording(
      BuildContext context, Function() goToClass, Function() nextSegmentAction, List<Segment> segments, int segmentIndex) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: OlukoNeumorphism.radiusValue,
        topRight: OlukoNeumorphism.radiusValue,
      ),
      child: Container(
        height: 100,
        decoration: const BoxDecoration(
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
          border: Border(top: BorderSide(color: OlukoColors.grayColorFadeTop)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OlukoNeumorphicSecondaryButton(
                    title: OlukoLocalizations.get(context, 'goToClass'),
                    textColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                    thinPadding: true,
                    onPressed: () {
                      goToClass();
                    },
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  OlukoNeumorphicPrimaryButton(
                    title: segmentIndex == segments.length - 1
                        ? OlukoLocalizations.get(context, 'done')
                        : OlukoLocalizations.get(context, 'nextSegment'),
                    thinPadding: true,
                    onPressed: () {
                      nextSegmentAction();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget neumporphicFinishedButtonsWithRecording(BuildContext context, Function() shareDoneAction) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: 50,
            width: ScreenUtils.width(context) - 40,
            child: OlukoNeumorphicPrimaryButton(
              isExpanded: false,
              title: OlukoLocalizations.get(context, 'done'),
              thinPadding: true,
              onPressed: () {
                shareDoneAction();
              },
            ),
          ),
        ],
      ),
    );
  }
}
