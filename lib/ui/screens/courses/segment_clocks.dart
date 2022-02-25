import 'dart:async';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_stream_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_update_bloc.dart';
import 'package:oluko_app/blocs/keyboard/keyboard_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart' as storyBloc;
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/alert.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/custom_keyboard.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/pause_dialog_content.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/modal_segment_movements.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_watch_app_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_round_alert.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/feedback_card.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/share_card.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/timer_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';

class SegmentClocks extends StatefulWidget {
  final WorkoutType workoutType;
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int segmentIndex;
  final List<Segment> segments;
  final int courseIndex;
  final bool fromChallenge;

  SegmentClocks(
      {Key key,
      this.courseIndex,
      this.workoutType,
      this.classIndex,
      this.segmentIndex,
      this.courseEnrollment,
      this.segments,
      this.fromChallenge})
      : super(key: key);

  @override
  _SegmentClocksState createState() => _SegmentClocksState();
}

class _SegmentClocksState extends State<SegmentClocks> {
  GlobalService _globalService = GlobalService();

  final toolbarHeight = kToolbarHeight * 2;
  //Imported from Timer POC Models
  WorkState workState;
  WorkState lastWorkStateBeforePause;

  //Current task running on Countdown Timer
  int timerTaskIndex = 0;
  Duration timeLeft;
  Timer countdownTimer;

  //Alert timer
  Duration alertTimeLeft;
  Timer alertTimer;
  bool alertTimerPlaying = false;

  //Alert timer
  Duration alertDurationTimeLeft;
  Timer alertDurationTimer;

  //Stopwatch
  Duration stopwatchDuration = Duration();
  Timer stopwatchTimer;

  //Flex proportions to display sections vertically in body.
  List<num> flexProportions(WorkoutType workoutType) => isSegmentWithRecording() ? [3, 7] : [8, 2];
  //Camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isReady = false;
  bool isCameraFront = false;
  List<TimerEntry> timerEntries;
  User _user;
  SegmentSubmission _segmentSubmission;
  List<Movement> _movements = [];
  bool isPlaying = true;
  PanelController panelController = PanelController();
  TextEditingController textController = TextEditingController();
  int AMRAPRound = 0;
  Widget topBarIcon;
  String processPhase = '';
  double progress = 0.0;
  bool isThereError = false;
  bool shareDone = false;
  WorkoutType workoutType;
  List<String> scores = [];
  int totalScore = 0;
  bool counter = false;
  bool _wantsToCreateStory = false;
  bool _isVideoUploaded = false;
  bool waitingForSegSubCreation = false;
  String _roundAlert = null;
  CoachRequest _coachRequest;
  XFile videoRecorded;
  bool _isFromChallenge = false;

  @override
  void initState() {
    Wakelock.enable();
    workoutType = widget.workoutType;
    if (isSegmentWithRecording()) {
      _setupCameras();
    }
    _startMovement();
    topBarIcon = const SizedBox();
    if (widget.segments[widget.segmentIndex].rounds != null) {
      scores = List<String>.filled(widget.segments[widget.segmentIndex].rounds, '-');
    }

    setState(() {
      _isFromChallenge = widget.fromChallenge ?? false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Wakelock.disable();
        return SegmentClocksUtils.onWillPop(context, isSegmentWithRecording());
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess) {
            _user = authState.firebaseUser;
            return BlocBuilder<MovementBloc, MovementState>(
              builder: (context, movementState) {
                return BlocBuilder<CoachRequestStreamBloc, CoachRequestStreamState>(
                  builder: (context, coachRequestStreamState) {
                    if (movementState is GetAllSuccess &&
                        (coachRequestStreamState is CoachRequestStreamSuccess || coachRequestStreamState is GetCoachRequestStreamUpdate)) {
                      List<CoachRequest> coachRequests;
                      if (coachRequestStreamState is CoachRequestStreamSuccess) {
                        coachRequests = coachRequestStreamState.values;
                      }
                      if (coachRequestStreamState is GetCoachRequestStreamUpdate) {
                        coachRequests = coachRequestStreamState.values;
                      }
                      _movements = movementState.movements;
                      _coachRequest = SegmentUtils.getSegmentCoachRequest(coachRequests, widget.segments[widget.segmentIndex].id);
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: BlocListener<SegmentSubmissionBloc, SegmentSubmissionState>(
                          listener: (context, state) {
                            if (state is CreateSuccess) {
                              if (_segmentSubmission == null) {
                                _segmentSubmission = state.segmentSubmission;
                                BlocProvider.of<VideoBloc>(context).createVideo(
                                  context,
                                  File(_segmentSubmission.videoState.stateInfo),
                                  3.0 / 4.0,
                                  _segmentSubmission.id,
                                  _segmentSubmission,
                                );
                                _globalService.videoProcessing = true;
                              }
                            } else if (state is UpdateSegmentSubmissionSuccess) {
                              waitingForSegSubCreation = false;
                              BlocProvider.of<CoachRequestStreamBloc>(context).resolve(_coachRequest, _user.uid);
                              if (_wantsToCreateStory) {
                                callBlocToCreateStory(context, state.segmentSubmission);
                              } else {
                                _isVideoUploaded = true;
                                _segmentSubmission = state?.segmentSubmission;
                              }
                            }
                          },
                          child: form(),
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                );
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Future<void> callBlocToCreateStory(BuildContext context, SegmentSubmission segmentSubmission) async {
    BlocProvider.of<storyBloc.StoryBloc>(context).createStory(segmentSubmission);
    AppMessages.clearAndShowSnackbarTranslated(context, 'storyCreated');
  }

  bool isSegmentWithRecording() {
    return workoutType == WorkoutType.segmentWithRecording;
  }

  bool isSegmentWithoutRecording() {
    return workoutType == WorkoutType.segment;
  }

  Widget form() {
    bool keyboardVisibilty = false;
    return Scaffold(
      extendBodyBehindAppBar: OlukoNeumorphism.isNeumorphismDesign,
      resizeToAvoidBottomInset: false,
      appBar: SegmentClocksUtils.getAppBar(context, topBarIcon, isSegmentWithRecording()),
      backgroundColor: Colors.black,
      body: workState != WorkState.finished
          ? BlocBuilder<KeyboardBloc, KeyboardState>(
              builder: (context, state) {
                keyboardVisibilty = state.setVisible;
                return !keyboardVisibilty && isSegmentWithoutRecording()
                    ? SlidingUpPanel(
                        controller: panelController,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        minHeight: 90.0,
                        maxHeight: 185.0,
                        collapsed: CollapsedMovementVideosSection(action: getPlayPauseAction()),
                        panel: MovementVideosSection(
                          action: getPlayPauseAction(),
                          segment: widget.segments[widget.segmentIndex],
                          movements: _movements,
                          onPressedMovement: (BuildContext context, Movement movement) =>
                              Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement}),
                        ),
                        body: _body(keyboardVisibilty),
                      )
                    : _body(keyboardVisibilty);
              },
            )
          : _body(keyboardVisibilty),
    );
  }

  Widget getPlayPauseAction() {
    return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: OlukoNeumorphism.isNeumorphismDesign ? neumorphicPlayPauseAction() : playPauseAction());
  }

  Widget neumorphicPlayPauseAction() {
    return Container(
      height: 35,
      width: 35,
      child: OlukoNeumorphicPrimaryButton(
        isExpanded: false,
        title: '',
        onlyIcon: true,
        onPressed: () {
          final bool isCurrentTaskTimed = timerEntries[timerTaskIndex].parameter == ParameterEnum.duration;
          setState(() {
            if (isPlaying) {
              panelController.open();
              if (isCurrentTaskTimed) {
                _pauseCountdown();
              } else {
                setPaused();
              }
              if (alertTimerPlaying) {
                alertTimer.cancel();
              }
            } else {
              panelController.close();
              workState = lastWorkStateBeforePause;
              if (isCurrentTaskTimed) {
                _playCountdown();
              } else {
                if (alertTimerPlaying) {
                  _playAlertTimer();
                }
              }
            }
            isPlaying = !isPlaying;
          });
        },
        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
      ),
    );
  }

  Widget playPauseAction() {
    return OutlinedButton(
      onPressed: () {
        final bool isCurrentTaskTimed = timerEntries[timerTaskIndex].parameter == ParameterEnum.duration;
        setState(() {
          if (isPlaying) {
            panelController.open();
            if (isCurrentTaskTimed) {
              _pauseCountdown();
            } else {
              setPaused();
            }
          } else {
            panelController.close();
            workState = lastWorkStateBeforePause;
            if (isCurrentTaskTimed) {
              _playCountdown();
            }
          }
          isPlaying = !isPlaying;
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        shape: const CircleBorder(),
        side: const BorderSide(color: Colors.white),
      ),
      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
    );
  }

  Widget _body(bool keyboardVisibilty) {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: Stack(children: [
        Column(
          children: [
            SizedBox(
              height: keyboardVisibilty
                  ? ScreenUtils.height(context)
                  : isWorkStateFinished()
                      ? ScreenUtils.height(context) * 0.4
                      : isSegmentWithoutRecording()
                          ? ScreenUtils.height(context)
                          : ScreenUtils.height(context) * 0.6,
              child: _timerSection(keyboardVisibilty),
            ),
            SizedBox(
              height: keyboardVisibilty
                  ? 0
                  : isWorkStateFinished()
                      ? ScreenUtils.height(context) * 0.46
                      : isSegmentWithoutRecording()
                          ? 0
                          : ScreenUtils.height(context) * 0.4,
              child: _lowerSection(),
            ),
          ],
        ),
        if (isWorkStateFinished())
          Positioned(
            bottom: 0,
            child: SizedBox(
              height: ScreenUtils.height(context) * 0.14,
              width: ScreenUtils.width(context),
              child: OlukoNeumorphism.isNeumorphismDesign ? neumorphicFinishedButtons() : showFinishedButtons(),
            ),
          )
        else
          const SizedBox(),
        if (_roundAlert != null)
          Positioned(
            top: isSegmentWithoutRecording() ? ScreenUtils.height(context) * 0.59 : ScreenUtils.height(context) * 0.55,
            left: ScreenUtils.width(context) / 3.8,
            child: OlukoRoundAlert(text: _roundAlert),
          )
        else
          const SizedBox.shrink(),
      ]),
    );
  }

  Widget showFinishedButtons() {
    if (widget.workoutType == WorkoutType.segmentWithRecording && !shareDone) {
      return finishedButtonsWithRecording();
    } else {
      return finishedButtonsWithoutRecording();
    }
  }

  Widget finishedButtonsWithRecording() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OlukoPrimaryButton(
            title: OlukoLocalizations.get(context, 'done'),
            thinPadding: true,
            onPressed: () {
              setState(() {
                shareDone = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget finishedButtonsWithoutRecording() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OlukoOutlinedButton(
            title: OlukoLocalizations.get(context, 'goToClass'),
            thinPadding: true,
            onPressed: () {
              goToClassAction();
            },
          ),
          const SizedBox(
            width: 15,
          ),
          OlukoPrimaryButton(
            title: widget.segmentIndex == widget.segments.length - 1
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

  Widget neumorphicFinishedButtons() {
    Wakelock.disable();
    if (widget.workoutType == WorkoutType.segmentWithRecording && !shareDone) {
      return neumporphicFinishedButtonsWithRecording();
    } else {
      return neumorphicFinishedButtonsWithoutRecording();
    }
  }

  Widget neumorphicFinishedButtonsWithoutRecording() {
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
                      goToClassAction();
                    },
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  OlukoNeumorphicPrimaryButton(
                    title: widget.segmentIndex == widget.segments.length - 1
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

  Widget neumporphicFinishedButtonsWithRecording() {
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
                setState(() {
                  shareDone = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void nextSegmentAction() {
    widget.segmentIndex < widget.segments.length - 1
        ? Navigator.popAndPushNamed(
            context,
            routeLabels[RouteEnum.segmentDetail],
            arguments: {
              'segmentIndex': widget.segmentIndex + 1,
              'classIndex': widget.classIndex,
              'courseEnrollment': widget.courseEnrollment,
              'courseIndex': widget.courseIndex,
              'fromChallenge': _isFromChallenge
            },
          )
        : Navigator.popAndPushNamed(
            context,
            routeLabels[RouteEnum.completedClass],
            arguments: {
              'classIndex': widget.classIndex,
              'courseEnrollment': widget.courseEnrollment,
              'courseIndex': widget.courseIndex,
            },
          );
  }

  void goToClassAction() {
    _isFromChallenge ? () {} : Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.insideClass]));
    Navigator.pushReplacementNamed(
      context,
      routeLabels[RouteEnum.insideClass],
      arguments: {'courseEnrollment': widget.courseEnrollment, 'classIndex': widget.classIndex, 'courseIndex': widget.courseIndex},
    );
  }

  ///Countdown & movements information
  Widget _timerSection(bool keyboardVisibilty) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Container(
            color: OlukoNeumorphismColors.appBackgroundColor,
            child: Column(
              children: [
                if (OlukoNeumorphism.isNeumorphismDesign) const SizedBox.shrink() else getSegmentLabel(),
                Padding(
                    padding: EdgeInsets.only(
                      top: SegmentClocksUtils.getWatchPadding(workState, usePulseAnimation()),
                    ),
                    child: ScreenUtils.height(context) < 700
                        ? SizedBox(
                            height: isWorkStateFinished() ? 215 : 250,
                            width: isWorkStateFinished() ? 215 : 250,
                            child: Stack(alignment: Alignment.center, children: [
                              if (usePulseAnimation()) roundTimerWithPulse(keyboardVisibilty) else getRoundsTimer(keyboardVisibilty),
                              _countdownSection(),
                            ]),
                          )
                        : Stack(alignment: Alignment.center, children: [
                            if (usePulseAnimation())
                              roundTimerWithPulse(keyboardVisibilty)
                            else
                              isWorkStateFinished()
                                  ? SizedBox(height: 250, width: 250, child: getRoundsTimer(keyboardVisibilty))
                                  : getRoundsTimer(keyboardVisibilty),
                            _countdownSection(),
                          ])),
              ],
            ),
          ),
        ),
        if (isWorkStateFinished())
          const SizedBox()
        else
          keyboardVisibilty
              ? Positioned(bottom: 0, child: _tasksSection(keyboardVisibilty))
              : Positioned(top: ScreenUtils.height(context) * 0.48, child: _tasksSection(keyboardVisibilty)),
      ],
    );
  }

  Widget roundTimerWithPulse(bool keyboardVisibilty) {
    return AvatarGlow(
      glowColor: OlukoNeumorphismColors.olukoNeumorphicGreenWatchColor,
      endRadius: 190,
      child: getRoundsTimer(keyboardVisibilty),
    );
  }

  //TODO: QUITAR ANIMACION  Y CIRCULAR

  bool usePulseAnimation() =>
      (OlukoNeumorphism.isNeumorphismDesign &&
          !(timerEntries[timerTaskIndex].counter == CounterEnum.reps || timerEntries[timerTaskIndex].counter == CounterEnum.distance)) &&
      (workState == WorkState.resting);

  bool isWorkStateFinished() {
    return workState == WorkState.finished;
  }

  bool isWorkStatePaused() {
    return workState == WorkState.paused;
  }

  Widget getSegmentLabel() {
    if (isWorkStateFinished()) {
      return const SizedBox();
    }
    if (SegmentUtils.isEMOM(widget.segments[widget.segmentIndex])) {
      return TimerUtils.getRoundLabel(timerEntries[timerTaskIndex].round);
    } else if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      return TimerUtils.getRoundLabel(AMRAPRound);
    } else {
      return const SizedBox();
    }
  }

  Widget getRoundsTimer(bool keyboardVisibilty) {
    if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && isWorkStateFinished()) {
      return TimerUtils.roundsTimer(AMRAPRound, AMRAPRound, keyboardVisibilty);
    } else if (isWorkStateFinished()) {
      return TimerUtils.roundsTimer(
        widget.segments[widget.segmentIndex].rounds,
        widget.segments[widget.segmentIndex].rounds,
        keyboardVisibilty,
      );
    } else if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      return TimerUtils.roundsTimer(AMRAPRound, AMRAPRound, keyboardVisibilty);
    } else {
      return TimerUtils.roundsTimer(widget.segments[widget.segmentIndex].rounds, timerEntries[timerTaskIndex].round, keyboardVisibilty);
    }
  }

  ///Current and next movement labels
  Widget _tasksSection(bool keyboardVisibilty) {
    return isSegmentWithoutRecording()
        ? taskSectionWithoutRecording(keyboardVisibilty)
        : Column(
            children: [
              if (OlukoNeumorphism.isNeumorphismDesign) const SizedBox.shrink() else const SizedBox(height: 10),
              SegmentClocksUtils.recordingTaskSection(keyboardVisibilty, context, timerEntries, timerTaskIndex),
              const SizedBox(
                height: 60,
              ),
              ...counterTextField(keyboardVisibilty),
              if (OlukoNeumorphism.isNeumorphismDesign) const SizedBox.shrink() else const SizedBox(height: 20),
            ],
          );
  }

  Widget taskSectionWithoutRecording(bool keyboardVisibilty) {
    //TODO: DIVIDERS
    final bool hasMultipleLabels = timerEntries[timerTaskIndex].labels.length > 1;
    if (hasMultipleLabels) {
      return SizedBox(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context) * 0.4,
        child: ListView(padding: EdgeInsets.zero, children: SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels)),
      );
    } else {
      final String currentTask = timerEntries[timerTaskIndex].labels[0];
      final String nextTask = timerTaskIndex < timerEntries.length - 1 ? timerEntries[timerTaskIndex + 1].labels[0] : '';
      return Padding(
        padding: OlukoNeumorphism.isNeumorphismDesign
            ? (workState == WorkState.resting && usePulseAnimation())
                ? const EdgeInsets.only(top: 40)
                : const EdgeInsets.only(top: 35)
            : EdgeInsets.zero,
        child: currentAndNextTaskWithCounter(keyboardVisibilty, currentTask, nextTask),
      );
    }
  }

  Widget currentAndNextTaskWithCounter(bool keyboardVisibilty, String currentTask, String nextTask) {
    return Column(
      children: [
        SizedBox(width: ScreenUtils.width(context) * 0.7, child: SegmentClocksUtils.currentTaskWidget(keyboardVisibilty, currentTask)),
        const SizedBox(height: 10),
        SizedBox(width: ScreenUtils.width(context), child: SegmentClocksUtils.nextTaskWidget(nextTask, keyboardVisibilty)),
        const SizedBox(height: 15),
        ...counterTextField(keyboardVisibilty),
      ],
    );
  }

  List<Widget> counterTextField(bool keyboardVisibilty) {
    if (isCurrentMovementRest() &&
        (timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps ||
            timerEntries[timerTaskIndex - 1].counter == CounterEnum.distance ||
            timerEntries[timerTaskIndex - 1].counter == CounterEnum.weight)) {
      final bool isCounterByReps = timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps;
      return [
        if (OlukoNeumorphism.isNeumorphismDesign) SizedBox.shrink() else getTextField(keyboardVisibilty),
        SegmentClocksUtils.getKeyboard(context, keyboardVisibilty),
        if (!keyboardVisibilty && !isSegmentWithRecording())
          SizedBox(
            height: ScreenUtils.height(context) / 4,
          )
        else
          SizedBox()
      ];
    } else {
      return [const SizedBox()];
    }
  }

  Container neumorphicTextfieldForScore(bool isCounterByReps) {
    //TODO: AJUSTAR EL INPUT
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      height: 65,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isCounterByReps ? ScreenUtils.width(context) / 6 : ScreenUtils.width(context) / 3.0,
                child: BlocBuilder<KeyboardBloc, KeyboardState>(
                  builder: (context, state) {
                    return Scrollbar(
                      controller: state.textScrollController,
                      child: () {
                        final _customKeyboardBloc = BlocProvider.of<KeyboardBloc>(context);
                        TextSelection textSelection = state.textEditingController.selection;
                        textSelection = state.textEditingController.selection.copyWith(
                          baseOffset: state.textEditingController.text.length,
                          extentOffset: state.textEditingController.text.length,
                        );
                        textController = state.textEditingController;
                        textController.selection = textSelection;

                        return TextField(
                          textAlign: TextAlign.center,
                          scrollController: state.textScrollController,
                          controller: textController,
                          onTap: () {
                            !state.setVisible ? _customKeyboardBloc.add(SetVisible()) : null;
                          },
                          style: const TextStyle(
                            fontSize: 32,
                            color: OlukoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          focusNode: state.focus,
                          readOnly: true,
                          showCursor: true,
                          decoration: InputDecoration(
                            isDense: false,
                            contentPadding: EdgeInsets.zero,
                            focusColor: Colors.transparent,
                            fillColor: Colors.transparent,
                            hintText: OlukoLocalizations.get(context, "enterScore"),
                            hintStyle: TextStyle(color: OlukoColors.grayColorSemiTransparent, fontSize: 18),
                            hintMaxLines: 1,
                            border: InputBorder.none,
                          ),
                        );
                      }(),
                    );
                  },
                ),
              ),
              // const SizedBox(width: 25),
              if (isCounterByReps)
                Text(
                  OlukoNeumorphism.isNeumorphismDesign && ScreenUtils.height(context) < 700
                      ? OlukoLocalizations.get(context, 'reps')
                      : timerEntries[timerTaskIndex - 1].movement.name,
                  style:
                      const TextStyle(fontSize: 18, color: OlukoColors.white, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w300),
                )
              else
                textController.value != null && textController.value.text != ""
                    ? Expanded(
                        child: Text(
                          OlukoLocalizations.get(context, 'meters'),
                          style: const TextStyle(fontSize: 24, color: OlukoColors.white, fontWeight: FontWeight.w300),
                        ),
                      )
                    : const SizedBox.shrink(),
            ],
          ),
          if (textController.value != null && textController.value.text != "")
            const SizedBox.shrink()
          else
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(height: 30),
                  Text(
                    'Tap here to type the score',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: OlukoColors.primary),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget getTextField(bool keyboardVisibilty) {
    CounterEnum currentCounter = timerEntries[timerTaskIndex - 1].counter;
    final bool isCounterByReps = currentCounter == CounterEnum.reps;
    List<String> counterTxt = SegmentClocksUtils.counterText(context, currentCounter, timerEntries[timerTaskIndex - 1].movement.name);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/courses/gray_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      height: 50,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 20),
              Text(counterTxt[0], style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300)),
              const SizedBox(width: 10),
              SizedBox(
                width: isCounterByReps ? 40 : 70,
                child: BlocBuilder<KeyboardBloc, KeyboardState>(
                  builder: (context, state) {
                    return Scrollbar(
                      controller: state.textScrollController,
                      child: () {
                        final _customKeyboardBloc = BlocProvider.of<KeyboardBloc>(context);
                        TextSelection textSelection = state.textEditingController.selection;
                        textSelection = state.textEditingController.selection.copyWith(
                          baseOffset: state.textEditingController.text.length,
                          extentOffset: state.textEditingController.text.length,
                        );
                        textController = state.textEditingController;
                        textController.selection = textSelection;

                        return TextField(
                          scrollController: state.textScrollController,
                          controller: textController,
                          onTap: () {
                            !state.setVisible ? _customKeyboardBloc.add(SetVisible()) : null;
                          },
                          style: const TextStyle(
                            fontSize: 20,
                            color: OlukoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          focusNode: state.focus,
                          readOnly: true,
                          showCursor: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        );
                      }(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 25),
              Text(counterTxt[1], style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300)),
            ],
          ),
        ],
      ),
    );
  }

  ///Clock countdown label
  Widget _countdownSection() {
    if (isWorkStateFinished()) {
      if (ScreenUtils.smallScreen(context)) {
        return SizedBox(
            height: 150,
            width: 150,
            child: TimerUtils.completedTimer(context,
                !SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) ? widget.segments[widget.segmentIndex].rounds : AMRAPRound));
      } else {
        return SizedBox(
            height: 180,
            width: 180,
            child: TimerUtils.completedTimer(context,
                !SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) ? widget.segments[widget.segmentIndex].rounds : AMRAPRound));
      }
    }

    if (!isWorkStatePaused() && (isCurrentTaskByReps() || isCurrentTaskByDistance())) {
      return BlocBuilder<KeyboardBloc, KeyboardState>(
        builder: (context, state) {
          BlocProvider.of<KeyboardBloc>(context).add(HideKeyboard());
          return TimerUtils.repsTimer(
            () => setState(() {
              _goToNextStep();
            }),
            context,
            timerEntries[timerTaskIndex].movement.isBothSide,
          );
        },
      );
    }

    if (isWorkStatePaused() && (isCurrentTaskByReps() || isCurrentTaskByDistance())) {
      return TimerUtils.pausedTimer(context);
    }

    final Duration actualTime = Duration(seconds: timerEntries[timerTaskIndex].value) - timeLeft;

    double circularProgressIndicatorValue = actualTime.inSeconds / timerEntries[timerTaskIndex].value;
    if (circularProgressIndicatorValue.isNaN) circularProgressIndicatorValue = 0;

    if (isWorkStatePaused()) {
      return TimerUtils.pausedTimer(context, TimeConverter.durationToString(timeLeft));
    }

    if (workState == WorkState.resting) {
      final bool needInput = useInput();
      if (timerEntries[timerTaskIndex].counter == CounterEnum.none && timeLeft.inSeconds <= 5) {
        return TimerUtils.finalTimer(
            InitialTimerType.End, 5, timeLeft.inSeconds, context, isLastEntryOfTheRound() ? timerEntries[timerTaskIndex].round : null);
      } else {
        return needInput && OlukoNeumorphism.isNeumorphismDesign
            ? TimerUtils.restTimer(
                needInput ? neumorphicTextfieldForScore(true) : null,
                circularProgressIndicatorValue,
                TimeConverter.durationToString(timeLeft),
                context,
              )
            : TimerUtils.restTimer(
                needInput ? getTextField(true) : null,
                circularProgressIndicatorValue,
                TimeConverter.durationToString(timeLeft),
                context,
              );
      }
    }

    if (timerEntries[timerTaskIndex].round == null) {
      //is AMRAP
      return TimerUtils.AMRAPTimer(
        circularProgressIndicatorValue,
        TimeConverter.durationToString(timeLeft),
        context,
        () {
          setState(() {
            AMRAPRound++;
          });
          if (AMRAPRound == 1) {
            _saveSegmentRound(timerEntries[timerTaskIndex]);
          }
        },
        AMRAPRound,
      );
    }
    final String counter = timerEntries[timerTaskIndex].counter == CounterEnum.reps ? timerEntries[timerTaskIndex].movement.name : null;

    if (timeLeft.inSeconds <= 5) {
      return TimerUtils.finalTimer(
          InitialTimerType.End, 5, timeLeft.inSeconds, context, isLastEntryOfTheRound() ? timerEntries[timerTaskIndex].round : null);
    } else {
      return TimerUtils.timeTimer(
        circularProgressIndicatorValue,
        TimeConverter.durationToString(timeLeft),
        context,
        counter,
        timerEntries[timerTaskIndex].movement.isBothSide,
      );
    }
  }

  bool useInput() => (isCurrentMovementRest() &&
      (timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps || timerEntries[timerTaskIndex - 1].counter == CounterEnum.distance));

  bool isLastEntryOfTheRound() {
    if (timerTaskIndex == timerEntries.length - 1) {
      return true;
    } else if (timerEntries[timerTaskIndex + 1].round != timerEntries[timerTaskIndex].round) {
      return true;
    } else {
      return false;
    }
  }

  ///Lower half of the view
  Widget _lowerSection() {
    if (workState != WorkState.finished) {
      return Container(
          color: Colors.black,
          child: isSegmentWithRecording()
              ? SegmentClocksUtils.cameraSection(context, isWorkStateFinished(), _isReady, cameraController, pauseButton())
              : const SizedBox());
    } else {
      return _segmentInfoSection();
    }
  }

  bool isCurrentTaskTimed() {
    return timerEntries[timerTaskIndex].parameter == ParameterEnum.duration;
  }

  bool isCurrentTaskByReps() {
    return timerEntries[timerTaskIndex].parameter == ParameterEnum.reps;
  }

  bool isCurrentTaskByDistance() {
    return timerEntries[timerTaskIndex].parameter == ParameterEnum.distance;
  }

  bool isCurrentMovementRest() {
    return timerEntries[timerTaskIndex].movement.isRestTime;
  }

  Widget pauseButton() {
    return GestureDetector(
        onTap: () async {
          setState(() {
            if (isCurrentTaskTimed()) {
              _pauseCountdown();
            } else {
              setPaused();
            }
          });
          if (isSegmentWithRecording()) {
            await cameraController.stopVideoRecording();
            BottomDialogUtils.showBottomDialog(
              context: context,
              content: PauseDialogContent(resumeAction: _resume, restartAction: _goToSegmentDetail),
            );
          }
          setState(() {
            workoutType = WorkoutType.segment;
            isPlaying = false;
          });
        },
        child: SegmentClocksUtils.pauseButton());
  }

  _goToSegmentDetail() {
    Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.segmentDetail]));
  }

  //Timer Functions
  _saveSegmentRound(TimerEntry timerEntry) async {
    if (isSegmentWithRecording()) {
      videoRecorded = await cameraController.stopVideoRecording();
      coachAction();
      setState(() {
        workoutType = WorkoutType.segment;
      });
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'roundInfo'));
    }
  }

  bool isLastOne() {
    return timerTaskIndex == timerEntries.length - 1;
  }

  bool nextIsFirstRound() {
    return timerEntries[timerTaskIndex + 1].round == 1;
  }

  bool nextIsLastOne() {
    return timerTaskIndex + 1 == timerEntries.length - 1;
  }

  bool nextIsRestTime() {
    return timerEntries[timerTaskIndex + 1].movement.isRestTime;
  }

  bool thereAreTwoMorePos() {
    return timerTaskIndex + 2 <= timerEntries.length - 1;
  }

  bool twoPosLaterIsFirstRound() {
    return timerEntries[timerTaskIndex + 2].round == 1;
  }

  void _goToNextStep() {
    if (alertTimer != null) {
      alertTimer.cancel();
    }

    if (!SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && timerEntries[timerTaskIndex].round == 0) {
      if ((isLastOne() || nextIsFirstRound()) ||
          ((nextIsLastOne() && nextIsRestTime()) || (thereAreTwoMorePos() && nextIsRestTime() && twoPosLaterIsFirstRound()))) {
        _saveSegmentRound(timerEntries[timerTaskIndex]);
      }
    }

    _saveCounter();

    _saveStopwatch();

    if (timerTaskIndex == timerEntries.length - 1) {
      setState(() {
        _roundAlert = null;
      });
      _finishWorkout();
      return;
    }

    setState(() {
      timerTaskIndex++;
      if (timerEntries[timerTaskIndex - 1].round != timerEntries[timerTaskIndex].round) {
        setAlert();
      }
      _playTask();
    });

    if (timerEntries[timerTaskIndex].stopwatch) {
      _startStopwatch();
    }
  }

  _saveStopwatch() {
    if (timerEntries[timerTaskIndex].stopwatch &&
        (timerTaskIndex == timerEntries.length - 1 ||
            timerEntries[timerTaskIndex].sectionIndex < timerEntries[timerTaskIndex + 1].sectionIndex ||
            timerEntries[timerTaskIndex].round < timerEntries[timerTaskIndex + 1].round)) {
      int currentDuration = stopwatchDuration.inSeconds;
      _stopAndResetStopwatch();
      BlocProvider.of<CourseEnrollmentUpdateBloc>(context).saveSectionStopwatch(
        widget.courseEnrollment,
        widget.segmentIndex,
        timerEntries[timerTaskIndex].sectionIndex,
        widget.classIndex,
        widget.segments[widget.segmentIndex].rounds,
        timerEntries[timerTaskIndex].round,
        currentDuration,
      );
    }
  }

  _saveCounter() {
    if (isCurrentMovementRest() &&
        timerEntries[timerTaskIndex - 1].movement.counter != null &&
        timerEntries[timerTaskIndex - 1].movement.counter != CounterEnum.none &&
        textController.text != '') {
      setState(() {
        counter = true;
      });

      addScoreEntry();

      BlocProvider.of<CourseEnrollmentUpdateBloc>(context).saveMovementCounter(
        widget.courseEnrollment,
        widget.segmentIndex,
        timerEntries[timerTaskIndex - 1].sectionIndex,
        widget.classIndex,
        timerEntries[timerTaskIndex - 1].movement,
        widget.segments[widget.segmentIndex].rounds,
        timerEntries[timerTaskIndex - 1].round,
        int.parse(textController.text),
      );
    }
    textController.clear();
  }

  addScoreEntry() {
    setState(() {
      totalScore += int.parse(textController.text);
    });
    scores[timerEntries[timerTaskIndex - 1].round] = textController.text + ' ' + timerEntries[timerTaskIndex - 1].movement.getLabel();
  }

  WorkState getCurrentTaskWorkState() {
    if (isCurrentMovementRest()) {
      return WorkState.resting;
    } else {
      return WorkState.exercising;
    }
  }

  _playTask() async {
    workState = getCurrentTaskWorkState();
    if (isCurrentTaskTimed()) {
      _playCountdown();
      timeLeft = Duration(seconds: timerEntries[timerTaskIndex].value);
    }
  }

  void _finishWorkout() {
    if (alertTimer != null) {
      alertTimer.cancel();
    }

    workState = WorkState.finished;

    print('Workout finished');
    BlocProvider.of<CourseEnrollmentBloc>(context).markSegmentAsCompleted(widget.courseEnrollment, widget.segmentIndex, widget.classIndex);
    Wakelock.disable();
    setState(() {
      if (_segmentSubmission != null && widget.workoutType == WorkoutType.segmentWithRecording && !_isVideoUploaded) {
        topBarIcon = SegmentClocksUtils.uploadingIcon();
      }
    });
  }

  setAlert() {
    _roundAlert = null;
    List<Alert> alerts = widget.segments[widget.segmentIndex].alerts;
    if (alerts != null && !alerts.isEmpty) {
      Alert alert;
      if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
        alert = alerts[0];
      } else {
        alert = alerts[timerEntries[timerTaskIndex].round];
      }
      playAlert(alert);
    }
  }

  playAlert(Alert alert) {
    if (alert != null) {
      if (alert.time > 0) {
        alertTimerPlaying = true;
        alertTimeLeft = Duration(seconds: alert.time);
        _playAlertTimer();
      } else {
        _roundAlert = alert.text;
        setAlertDuration(5);
      }
    } else {
      _roundAlert = null;
    }
  }

  void _playAlertTimer() {
    alertTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (alertTimeLeft.inSeconds == 0) {
        alertTimerPlaying = false;
        alertTimer.cancel();
        if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
          _roundAlert = widget.segments[widget.segmentIndex].alerts[0].text;
        } else {
          _roundAlert = widget.segments[widget.segmentIndex].alerts[timerEntries[timerTaskIndex].round].text;
        }
        setAlertDuration(5);
        return;
      }
      setState(() {
        alertTimeLeft = Duration(seconds: alertTimeLeft.inSeconds - 1);
      });
    });
  }

  setAlertDuration(int seconds) {
    alertDurationTimeLeft = Duration(seconds: seconds);
    _playAlertDurationTimer();
  }

  void _playAlertDurationTimer() {
    alertDurationTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (alertDurationTimeLeft.inSeconds == 0) {
        alertDurationTimer.cancel();
        _roundAlert = null;
        return;
      }
      setState(() {
        alertDurationTimeLeft = Duration(seconds: alertDurationTimeLeft.inSeconds - 1);
      });
    });
  }

  _startMovement() {
    //Reset countdown variables
    timerTaskIndex = 0;
    timerEntries = SegmentUtils.getExercisesList(widget.segments[widget.segmentIndex]);
    if (timerEntries.isEmpty) {
      _finishWorkout();
      return;
    }
    if (timerEntries[0].stopwatch) {
      _startStopwatch();
      Wakelock.enable();
    }
    _playTask();
    setAlert();
  }

  void _playCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (timeLeft.inSeconds == 0) {
        _pauseCountdown();
        _goToNextStep();
        return;
      }
      setState(() {
        timeLeft = Duration(seconds: timeLeft.inSeconds - 1);
      });
    });
    if (alertTimerPlaying) {
      _playAlertTimer();
    }
  }

  void setPaused() {
    lastWorkStateBeforePause = workState;
    workState = WorkState.paused;
  }

  void _pauseCountdown() {
    setPaused();
    countdownTimer.cancel();
  }

  @override
  void dispose() {
    Wakelock.disable();
    if (countdownTimer != null && countdownTimer.isActive) {
      countdownTimer.cancel();
    }
    if (stopwatchTimer != null && stopwatchTimer.isActive) {
      stopwatchTimer.cancel();
    }
    if (alertDurationTimer != null && alertDurationTimer.isActive) {
      alertDurationTimer.cancel();
    }
    if (alertTimer != null && alertTimer.isActive) {
      alertTimer.cancel();
    }
    cameraController?.dispose();
    super.dispose();
  }

  //Camera functions
  Future<void> _setupCameras() async {
    final int cameraPos = isCameraFront ? 0 : 1;
    try {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[cameraPos], ResolutionPreset.medium);
      await cameraController.initialize();
      await cameraController.startVideoRecording();
    } on CameraException catch (_) {}
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

  ///Section with information about segment and workout movements.
  Widget _segmentInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: OlukoNeumorphism.isNeumorphismDesign ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: MovementUtils.movementTitle(
                    widget.segments[widget.segmentIndex].isChallenge
                        ? OlukoLocalizations.get(context, 'challengeTitle') + widget.segments[widget.segmentIndex].name
                        : widget.segments[widget.segmentIndex].name,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (counter)
            SizedBox(
                height: ScreenUtils.height(context) * 0.15,
                child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: SegmentClocksUtils.getScoresByRound(context, timerEntries, timerTaskIndex, totalScore, scores)))
          else
            OlukoNeumorphism.isNeumorphismDesign
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                        height: ScreenUtils.height(context) * 0.12,
                        width: ScreenUtils.width(context),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: SegmentUtils.getWorkouts(widget.segments[widget.segmentIndex], OlukoColors.grayColor),
                        )),
                  )
                : Column(children: SegmentUtils.getWorkouts(widget.segments[widget.segmentIndex], OlukoColors.grayColor)),
          widget.workoutType == WorkoutType.segment || shareDone
              ? FeedbackCard()
              : ShareCard(createStory: _createStory, whistleAction: whistleAction),
        ],
      ),
    );
  }

  whistleAction(bool delete) {
    BlocProvider.of<SegmentSubmissionBloc>(context).setIsDeleted(_segmentSubmission, delete);
  }

  _createStory() {
    _wantsToCreateStory = true;
    if (waitingForSegSubCreation) {
      if (_isVideoUploaded) {
        callBlocToCreateStory(context, _segmentSubmission);
      }
    } else {
      if (_segmentSubmission == null) {
        createSegmentSubmission();
      } else if (_isVideoUploaded) {
        callBlocToCreateStory(context, _segmentSubmission);
      }
    }
  }

  coachAction() {
    if (!waitingForSegSubCreation) {
      createSegmentSubmission();
    }
  }

  createSegmentSubmission() {
    waitingForSegSubCreation = true;
    BlocProvider.of<SegmentSubmissionBloc>(context)
        .create(_user, widget.courseEnrollment, widget.segments[widget.segmentIndex], videoRecorded.path, _coachRequest);
  }

//STOPWATCH FUNCTIONS
  void _startStopwatch() {
    stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) => _addTime());
  }

  _addTime() {
    final int addSeconds = 1;
    setState(() {
      final int seconds = stopwatchDuration.inSeconds + addSeconds;
      stopwatchDuration = Duration(seconds: seconds);
    });
  }

  _stopAndResetStopwatch() {
    setState(() {
      stopwatchTimer.cancel();
      stopwatchDuration = Duration();
    });
  }

  _resume() {
    setState(() {
      workState = WorkState.exercising;
      _playCountdown();
      isPlaying = true;
    });
  }
}
