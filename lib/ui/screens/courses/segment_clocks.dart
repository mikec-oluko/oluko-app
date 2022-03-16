import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/clocks_timer_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_stream_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_update_bloc.dart';
import 'package:oluko_app/blocs/keyboard/keyboard_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/timer_task_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/enums/request_status_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/alert.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/clock.dart';
import 'package:oluko_app/ui/components/clocks_lower_section.dart';
import 'package:oluko_app/ui/components/pause_dialog_content.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_round_alert.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:oluko_app/utils/sound_utils.dart';
import 'package:oluko_app/utils/story_utils.dart';
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

  const SegmentClocks(
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
                                BlocProvider.of<CoachRequestStreamBloc>(context)
                                    .resolve(_coachRequest, _user.uid, RequestStatusEnum.ignored);
                              }
                            } else if (state is UpdateSegmentSubmissionSuccess) {
                              waitingForSegSubCreation = false;
                              BlocProvider.of<CoachRequestStreamBloc>(context)
                                  .resolve(_coachRequest, _user.uid, RequestStatusEnum.resolved);
                              if (_wantsToCreateStory) {
                                StoryUtils.callBlocToCreateStory(
                                    context, state.segmentSubmission, totalScore, widget.segments[widget.segmentIndex]);
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

  CoachRequest getSegmentCoachRequest(List<CoachRequest> coachRequests, String segmentId) {
    for (var i = 0; i < coachRequests.length; i++) {
      if (coachRequests[i].segmentId == segmentId) {
        return coachRequests[i];
      }
    }
    return null;
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
                BlocProvider.of<ClocksTimerBloc>(context).pauseCountdown(setPaused);
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
                BlocProvider.of<ClocksTimerBloc>(context).playCountdown(_goToNextStep, setPaused);
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
              BlocProvider.of<ClocksTimerBloc>(context).pauseCountdown(setPaused);
            } else {
              setPaused();
            }
          } else {
            panelController.close();
            workState = lastWorkStateBeforePause;
            if (isCurrentTaskTimed) {
              BlocProvider.of<ClocksTimerBloc>(context).playCountdown(_goToNextStep, setPaused);
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
              child: Clock(
                workState: workState,
                segments: widget.segments,
                segmentIndex: widget.segmentIndex,
                timerEntries: timerEntries,
                textController: textController,
                goToNextStep: _goToNextStep,
                actionAMRAP: actionAMRAP,
                setPaused: setPaused,
                workoutType: workoutType,
                keyboardVisibilty: keyboardVisibilty,
              ),
            ),
            SizedBox(
                height: keyboardVisibilty
                    ? 0
                    : isWorkStateFinished()
                        ? ScreenUtils.height(context) * 0.46
                        : isSegmentWithoutRecording()
                            ? 0
                            : ScreenUtils.height(context) * 0.4,
                child: ClocksLowerSection(
                  workState: workState,
                  segments: widget.segments,
                  segmentIndex: widget.segmentIndex,
                  timerEntries: timerEntries,
                  timerTaskIndex: timerTaskIndex,
                  createStory: _createStory,
                  workoutType: workoutType,
                  originalWorkoutType: widget.workoutType,
                  //shareDone: shareDone,
                  segmentSubmission: _segmentSubmission,
                  scores: scores,
                  totalScore: totalScore,
                  counter: counter,
                  isCameraReady: _isReady,
                  cameraController: cameraController,
                  pauseButton: pauseButton(),
                  classIndex: widget.classIndex,
                  courseEnrollment: widget.courseEnrollment,
                  segmentId: widget.segments[widget.segmentIndex].id,
                )),
          ],
        ),
        if (isWorkStateFinished())
          Positioned(
            bottom: 0,
            child: SizedBox(
              height: ScreenUtils.height(context) * 0.14,
              width: ScreenUtils.width(context),
              child: SegmentClocksUtils.showButtonsWhenFinished(workoutType, shareDone, context, shareDoneAction, goToClassAction,
                  nextSegmentAction, widget.segments, widget.segmentIndex),
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

  void shareDoneAction() {
    setState(() {
      shareDone = true;
    });
    BlocProvider.of<TimerTaskBloc>(context).setShareDone(shareDone);
  }

  void nextSegmentAction() {
    if (widget.segmentIndex < widget.segments.length - 1) {
      Navigator.popAndPushNamed(
        context,
        routeLabels[RouteEnum.segmentDetail],
        arguments: {
          'segmentIndex': widget.segmentIndex + 1,
          'classIndex': widget.classIndex,
          'courseEnrollment': widget.courseEnrollment,
          'courseIndex': widget.courseIndex,
          'fromChallenge': _isFromChallenge
        },
      );
    } else {
      SoundPlayer.playAsset(soundEnum: SoundsEnum.classFinished);
      Navigator.popAndPushNamed(
        context,
        routeLabels[RouteEnum.completedClass],
        arguments: {
          'classIndex': widget.classIndex,
          'courseEnrollment': widget.courseEnrollment,
          'courseIndex': widget.courseIndex,
        },
      );
    }
  }

  void goToClassAction() {
    _isFromChallenge ? () {} : Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.insideClass]));
    Navigator.pushReplacementNamed(
      context,
      routeLabels[RouteEnum.insideClass],
      arguments: {'courseEnrollment': widget.courseEnrollment, 'classIndex': widget.classIndex, 'courseIndex': widget.courseIndex},
    );
  }

  bool isWorkStateFinished() {
    return workState == WorkState.finished;
  }

  void actionAMRAP() {
    AMRAPRound++;

    BlocProvider.of<TimerTaskBloc>(context).setAMRAPRound(AMRAPRound);

    if (AMRAPRound == 1) {
      _saveSegmentRound();
    }
  }

  bool isCurrentTaskTimed() {
    return timerEntries[timerTaskIndex].parameter == ParameterEnum.duration;
  }

  bool isCurrentMovementRest() {
    return timerEntries[timerTaskIndex].movement.isRestTime;
  }

  Widget pauseButton() {
    return GestureDetector(
        onTap: () async {
          setState(() {
            if (isCurrentTaskTimed()) {
              BlocProvider.of<ClocksTimerBloc>(context).pauseCountdown(setPaused);
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
  void _saveSegmentRound() async {
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
        _saveSegmentRound();
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

    timerTaskIndex++;
    if (timerEntries[timerTaskIndex - 1].round != timerEntries[timerTaskIndex].round) {
      setAlert();
    }
    _playTask();
    BlocProvider.of<TimerTaskBloc>(context).setTimerTaskIndex(timerTaskIndex);

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
      BlocProvider.of<ClocksTimerBloc>(context).playCountdown(_goToNextStep, setPaused);
      BlocProvider.of<ClocksTimerBloc>(context).updateTimeLeft();
    }
  }

  void _finishWorkout() {
    if (alertTimer != null) {
      alertTimer.cancel();
    }

    workState = WorkState.finished;

    print('Workout finished');
    BlocProvider.of<CourseEnrollmentBloc>(context).markSegmentAsCompleted(widget.courseEnrollment, widget.segmentIndex, widget.classIndex);

    if (widget.segments[widget.segmentIndex].isChallenge) {
      StoryUtils.createNewPRChallengeStory(context, totalScore, _user.uid, widget.segments[widget.segmentIndex]);
    }

    Wakelock.disable();
    setState(() {
      if (_segmentSubmission != null && widget.workoutType == WorkoutType.segmentWithRecording && !_isVideoUploaded) {
        topBarIcon = SegmentClocksUtils.uploadingIcon();
      }
    });
  }

  setAlert() {
    _roundAlert = null;
    final List<Alert> alerts = widget.segments[widget.segmentIndex].alerts;
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
      alertTimeLeft = Duration(seconds: alertTimeLeft.inSeconds - 1);
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
      alertDurationTimeLeft = Duration(seconds: alertDurationTimeLeft.inSeconds - 1);
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

  void setPaused() {
    lastWorkStateBeforePause = workState;
    workState = WorkState.paused;
  }

  @override
  void dispose() {
    Wakelock.disable();
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

  _createStory() {
    _wantsToCreateStory = true;
    if (waitingForSegSubCreation) {
      if (_isVideoUploaded) {
        StoryUtils.callBlocToCreateStory(context, _segmentSubmission, totalScore, widget.segments[widget.segmentIndex]);
      }
    } else {
      if (_segmentSubmission == null) {
        createSegmentSubmission();
      } else if (_isVideoUploaded) {
        StoryUtils.callBlocToCreateStory(context, _segmentSubmission, totalScore, widget.segments[widget.segmentIndex]);
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
    final int seconds = stopwatchDuration.inSeconds + addSeconds;
    stopwatchDuration = Duration(seconds: seconds);
  }

  _stopAndResetStopwatch() {
    stopwatchTimer.cancel();
    stopwatchDuration = Duration();
  }

  _resume() {
    setState(() {
      workState = WorkState.exercising;
      BlocProvider.of<ClocksTimerBloc>(context).playCountdown(_goToNextStep, setPaused);
      isPlaying = true;
    });
  }
}
