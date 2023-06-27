import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/animation_bloc.dart';
import 'package:oluko_app/blocs/notification_settings_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/notification_settings.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/custom_keyboard.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/modal_segment_movements.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_watch_app_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:wakelock/wakelock.dart';

enum WorkoutType { segment, segmentWithRecording }

class SegmentClocksUtils {
  static List<Widget> getScoresByRound(BuildContext context, List<TimerEntry> timerEntries, int timerTaskIndex, int totalScore, List<String> scores,
      [bool areDiferentMovsWithRepCouter]) {
    List<String> lbls = counterText(context, timerEntries[timerEntries[timerTaskIndex - 1].movement.isRestTime ? timerTaskIndex : timerTaskIndex - 1].counter,
        timerEntries[timerTaskIndex - 1].movement.name);
    final List<Widget> widgets = [];
    String totalText = '${OlukoLocalizations.get(context, 'total')}: $totalScore ';

    if (areDiferentMovsWithRepCouter != null && areDiferentMovsWithRepCouter) {
      totalText += SegmentUtils.getCounterInputLabel(timerEntries[timerTaskIndex - 1].counter);
    } else {
      if (!lbls.isEmpty) {
        totalText += lbls[1];
      } else {
        String seconds = TimeConverter.durationToString(Duration(seconds: totalScore));
        totalText = '${OlukoLocalizations.get(context, 'total')}: $seconds ';
      }
    }

    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: ScreenUtils.width(context) - 40,
              child: Text(totalText, style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.primary))),
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
                style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.white),
              ),
              SizedBox(
                width: ScreenUtils.width(context) * 0.5,
                child: Text(
                  scores[i],
                  textAlign: TextAlign.end,
                  style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400, customColor: OlukoColors.white),
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

  static Widget nextTaskWidget(String nextTask) {
    return Visibility(
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [OlukoColors.black, Colors.transparent],
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

  static Future<bool> onWillPopConfirmationPopup(BuildContext contextWBloc, bool isRecording) async {
    bool result = false;
    (await showDialog(
      context: contextWBloc,
      builder: (context) => AlertDialog(
        backgroundColor: OlukoColors.black,
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
          TextButton(
            onPressed: () {
              BlocProvider.of<AnimationBloc>(context).playPauseAnimation();
              Navigator.of(context).pop();
              result = true;
            },
            child: Text(
              OlukoLocalizations.get(context, 'yes'),
            ),
          )
        ],
      ),
    ));

    return result;
  }

  static PreferredSizeWidget getAppBar(
      BuildContext context, Widget topBarIcon, bool segmentWithRecording, WorkoutType workout, Function() resetAMRAP, Function() deleteUserProgress) {
    PreferredSizeWidget appBarToUse;
    if (OlukoNeumorphism.isNeumorphismDesign) {
      appBarToUse = OlukoWatchAppBar(
        onPressed: () async {
          if (await onWillPopConfirmationPopup(context, segmentWithRecording)) {
            resetAMRAP();
            deleteUserProgress();
            segmentClockOnWillPop(context);
          }
        },
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

  static bool segmentClockOnWillPop(BuildContext context) {
    BlocProvider.of<AnimationBloc>(context).playPauseAnimation();
    Wakelock.disable();
    Navigator.of(context).popUntil(ModalRoute.withName(routeLabels[RouteEnum.segmentDetail]));
    return false;
  }

  static Widget audioIcon() {
    bool audioOff = !NotificationSettingsBloc.notificationSettings.segmentClocksSounds;
    return BlocBuilder<NotificationSettingsBloc, NotificationSettingsState>(
      builder: (context, state) {
        if (state is NotificationSettingsUpdate && state.notificationSettings != null) {
          audioOff = !state.notificationSettings.segmentClocksSounds;
        }
        return GestureDetector(
          onTap: () {
            BlocProvider.of<NotificationSettingsBloc>(context)
                .update(NotificationSettings(segmentClocksSounds: !NotificationSettingsBloc.notificationSettings.segmentClocksSounds));
          },
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    child: Image.asset(
                      OlukoNeumorphism.isNeumorphismDesign ? 'assets/courses/audio_icon_neumorphic.png' : 'assets/courses/audio_icon.png',
                      scale: 4,
                    ),
                  ),
                  if (audioOff)
                    SizedBox(
                      width: 19,
                      height: 19,
                      child: Image.asset(
                        'assets/utils/diagonal.png',
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget recordingTaskSection(BuildContext context, List<TimerEntry> timerEntries, int timerTaskIndex) {
    final bool hasMultipleLabels = timerEntries[timerTaskIndex].labels.length > 1;
    if (hasMultipleLabels) {
      final List<Widget> items = SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels);
      if (timerTaskIndex == 0) {
        return SizedBox(
          width: ScreenUtils.width(context),
          height: ScreenUtils.height(context) * 0.4,
          child: ListView(
              physics: OlukoNeumorphism.listViewPhysicsEffect,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              padding: EdgeInsets.zero,
              children: SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels)),
        );
      } else {
        return SizedBox(
          width: 200,
          child: OlukoNeumorphicSecondaryButton(
            lighterButton: true,
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
      }
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
              SizedBox(width: ScreenUtils.width(context) * 0.7, child: currentTaskWidget(currentTask, true)),
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

  static Widget currentTaskWidget(String currentTask, [bool smaller = false]) {
    return Visibility(
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
              style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w400),
              textAlign: TextAlign.start,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.upload, color: Colors.white)
          ],
        ),
      ),
    );
  }

  static Widget cameraSection(BuildContext context, bool isWorkStatePaused, bool isCameraReady, CameraController cameraController, Widget pauseButton) {
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
                Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: pauseButton)),
              ],
            ),
          );
  }

  static Widget pauseButton() {
    return Stack(alignment: Alignment.center, children: [
      Image.asset(
        'assets/neumorphic/button_shade.png',
        scale: 4.4,
      ),
      Padding(
          padding: EdgeInsets.only(left: 2, top: 1),
          child: Image.asset(
            'assets/neumorphic/record_button.png',
            scale: 7,
          )),
    ]);
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
      BuildContext context, Function() goToClass, Function() nextSegmentAction, List<Segment> segments, int segmentIndex, Function() deleteUserProgress) {
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
              deleteUserProgress();
            },
          ),
          const SizedBox(
            width: 15,
          ),
          OlukoPrimaryButton(
            title: segmentIndex == segments.length - 1 ? OlukoLocalizations.get(context, 'done') : OlukoLocalizations.get(context, 'nextSegment'),
            thinPadding: true,
            onPressed: () {
              nextSegmentAction();
              deleteUserProgress();
            },
          ),
        ],
      ),
    );
  }

  static Widget showButtonsWhenFinished(WorkoutType workoutType, bool shareDone, BuildContext context, Function() shareDoneAction, Function() goToClass,
      Function() nextSegmentAction, List<Segment> segments, int segmentIndex, Function() deleteUserProgress) {
    return !OlukoNeumorphism.isNeumorphismDesign
        ? showFinishedButtons(workoutType, shareDone, context, shareDoneAction, goToClass, nextSegmentAction, segments, segmentIndex, deleteUserProgress)
        : neumorphicFinishedButtons(workoutType, shareDone, context, shareDoneAction, goToClass, nextSegmentAction, segments, segmentIndex, deleteUserProgress);
  }

  static Widget showFinishedButtons(WorkoutType workoutType, bool shareDone, BuildContext context, Function() shareDoneAction, Function() goToClass,
      Function() nextSegmentAction, List<Segment> segments, int segmentIndex, Function() deleteUserProgress) {
    if (workoutType == WorkoutType.segmentWithRecording && !shareDone) {
      return finishedButtonsWithRecording(context, shareDoneAction);
    } else {
      return finishedButtonsWithoutRecording(context, goToClass, nextSegmentAction, segments, segmentIndex, deleteUserProgress);
    }
  }

  static Widget neumorphicFinishedButtons(WorkoutType workoutType, bool shareDone, BuildContext context, Function() shareDoneAction, Function() goToClass,
      Function() nextSegmentAction, List<Segment> segments, int segmentIndex, Function() deleteUserProgress) {
    Wakelock.disable();
    if (workoutType == WorkoutType.segmentWithRecording && !shareDone) {
      return neumporphicFinishedButtonsWithRecording(context, shareDoneAction);
    } else {
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: OlukoNeumorphicDivider(
              isFadeOut: true,
            ),
          ),
          neumorphicFinishedButtonsWithoutRecording(context, goToClass, nextSegmentAction, segments, segmentIndex, deleteUserProgress),
        ],
      );
    }
  }

  static Widget neumorphicFinishedButtonsWithoutRecording(
      BuildContext context, Function() goToClass, Function() nextSegmentAction, List<Segment> segments, int segmentIndex, Function() deleteUserProgress) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: OlukoNeumorphism.radiusValue,
        topRight: OlukoNeumorphism.radiusValue,
      ),
      child: Container(
        height: 100,
        decoration: const BoxDecoration(
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Container(
              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OlukoNeumorphicSecondaryButton(
                    lighterButton: true,
                    title: OlukoLocalizations.get(context, 'goToClass'),
                    thinPadding: true,
                    onPressed: () {
                      goToClass();
                      deleteUserProgress();
                    },
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  OlukoNeumorphicPrimaryButton(
                    title: segmentIndex == segments.length - 1 ? OlukoLocalizations.get(context, 'done') : OlukoLocalizations.get(context, 'nextSegment'),
                    thinPadding: true,
                    onPressed: () {
                      nextSegmentAction();
                      deleteUserProgress();
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

  static bool diferentMovsWithRepCouter(List<TimerEntry> timerEntries) {
    String firstMov = timerEntries[0].movement.id;
    for (final t in timerEntries) {
      if (!t.movement.isRestTime && t.movement.id != firstMov) {
        return true;
      }
    }
    return false;
  }
}
