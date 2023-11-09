import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:oluko_app/blocs/amrap_round_bloc.dart';
import 'package:oluko_app/blocs/animation_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/clocks_timer_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_stream_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_update_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/movement_weight_bloc.dart';
import 'package:oluko_app/blocs/personal_record_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/profile/max_weights_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/segments/current_time_bloc.dart';
import 'package:oluko_app/blocs/stopwatch_bloc.dart';
import 'package:oluko_app/blocs/timer_task_bloc.dart';
import 'package:oluko_app/blocs/user_progress_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/challenge_type_enum.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/enums/personal_record_param.dart';
import 'package:oluko_app/models/enums/request_status_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/alert.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/rounds_alerts.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/clock.dart';
import 'package:oluko_app/ui/components/clocks_lower_section.dart';
import 'package:oluko_app/ui/components/coach_request_content.dart';
import 'package:oluko_app/ui/components/pause_dialog_content.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_round_alert.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/initial_timer_panel.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:oluko_app/utils/story_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/timer_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';
//import 'package:native_device_orientation/native_device_orientation.dart';

class SegmentClocks extends StatefulWidget {
  final WorkoutType workoutType;
  final CourseEnrollment courseEnrollment;
  final CoachRequest coachRequest;
  final int classIndex;
  final int segmentIndex;
  final List<Segment> segments;
  final int courseIndex;
  final bool fromChallenge;
  final UserResponse coach;
  final bool showPanel;
  final Function() onShowAgainPressed;
  final int currentTaskIndex;

  const SegmentClocks({
    Key key,
    this.courseIndex,
    this.workoutType,
    this.classIndex,
    this.coach,
    this.segmentIndex,
    this.courseEnrollment,
    this.segments,
    this.fromChallenge,
    this.showPanel,
    this.onShowAgainPressed,
    this.currentTaskIndex,
    this.coachRequest,
  }) : super(key: key);

  @override
  _SegmentClocksState createState() => _SegmentClocksState();
}

class _SegmentClocksState extends State<SegmentClocks> with WidgetsBindingObserver {
  GlobalService _globalService = GlobalService();
  final _headsetPlugin = HeadsetEvent();
  HeadsetState _headsetState;

  final toolbarHeight = kToolbarHeight * 2;
  //Imported from Timer POC Models
  WorkState workState;
  WorkState lastWorkStateBeforePause = WorkState.countdown;

  //Current task running on Countdown Timer
  int timerTaskIndex = 0;

  int realTaskIndex = 0;

  //Alert timer
  Duration alertDuration = Duration.zero;
  Timer alertTimer;
  bool alertTimerPlaying = false;

  List<Alert> _currentRoundAlerts = [];
  int _alertIndex = 0;
  int _alertTotalDuration = 5;

  //Stopwatch
  Duration stopwatchDuration = Duration();
  Timer stopwatchTimer;

  //Flex proportions to display sections vertically in body.
  List<num> flexProportions(WorkoutType workoutType) => isSegmentWithRecording() ? [3, 7] : [8, 2];
  //Camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isCameraReady = false;
  bool isCameraFront = false;
  List<TimerEntry> timerEntries;
  User _user;
  SegmentSubmission _segmentSubmission;
  bool isPlaying = true;
  PanelController panelController = PanelController();
  PanelController recordingPanelController = PanelController();
  TextEditingController textController = TextEditingController();
  int AMRAPRound = 0;
  Widget topBarIcon;
  String processPhase = '';
  double progress = 0.0;
  bool isThereError = false;
  bool shareDone = false;
  WorkoutType workoutType;
  List<String> scores = [];
  List<int> scoresInt = [];
  int totalScore = 0;
  bool counter = false;
  bool _wantsToCreateStory = false;
  bool _isVideoUploaded = false;
  bool waitingForSegSubCreation = false;
  CoachRequest _coachRequest;
  XFile videoRecorded;
  bool _isFromChallenge = false;
  Duration currentTime;
  bool open = true;
  int durationPR = 0;
  bool _recordingPaused = false;
  bool _progressCreated = false;
  bool _areDiferentMovsWithRepCouter = false;
  List<FriendModel> _friends = [];
  final SoundPlayer _soundPlayer = SoundPlayer();
  bool storyShared = false;
  List<WorkoutWeight> movementsAndWeightsToSave = [];
  UserResponse currentUser;
  GlobalKey<TooltipState> personalRecordTooltipKey = GlobalKey<TooltipState>();
  bool existPersonalRecordMovement = false;
  bool recordingNotificationIsShow = false;
  bool segmentIsOneRound = true;
  final String _recordingNotificationSound = 'sounds/recording_notification.wav';

  @override
  void initState() {
    Wakelock.enable();
    WidgetsBinding.instance.addObserver(this);
    workoutType = widget.workoutType;
    setState(() {
      _isFromChallenge = widget.fromChallenge ?? false;
      segmentIsOneRound = widget.segments[widget.segmentIndex].rounds == 1;
    });
    _startMovement();
    topBarIcon = const SizedBox();
    if (widget.segments[widget.segmentIndex].rounds != null) {
      scores = List<String>.filled(widget.segments[widget.segmentIndex].rounds, '-');
      scoresInt = List<int>.filled(widget.segments[widget.segmentIndex].rounds, 0);
    }

    _headsetPlugin.getCurrentState.then((_val) {
      setState(() {
        _headsetState = _val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return WillPopScope(
      onWillPop: () async {
        if (await SegmentClocksUtils.onWillPopConfirmationPopup(context, workoutType == WorkoutType.segmentWithRecording)) {
          resetAMRAPRound();
          deleteUserProgress();
          return SegmentClocksUtils.segmentClockOnWillPop(context);
        }
        return false;
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess) {
            _user = authState.firebaseUser;
            currentUser = authState.user;

            BlocProvider.of<FriendBloc>(context).getFriendsDataByUserId(_user.uid);
            return BlocBuilder<CoachRequestStreamBloc, CoachRequestStreamState>(
              builder: (context, coachRequestStreamState) {
                if (coachRequestStreamState is CoachRequestStreamSuccess || coachRequestStreamState is GetCoachRequestStreamUpdate) {
                  List<CoachRequest> coachRequests;
                  if (coachRequestStreamState is CoachRequestStreamSuccess) {
                    coachRequests = coachRequestStreamState.values;
                  }
                  if (coachRequestStreamState is GetCoachRequestStreamUpdate) {
                    coachRequests = coachRequestStreamState.values;
                  }
                  _coachRequest = SegmentUtils.getSegmentCoachRequest(coachRequests, widget.segments[widget.segmentIndex].id, widget.courseEnrollment.id,
                      widget.courseEnrollment.classes[widget.classIndex].id);
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
                              segmentSubmission: _segmentSubmission,
                              coachRequest: _coachRequest,
                            );

                            _globalService.videoProcessing = true;
                          }
                        } else if (state is SaveSegmentSubmissionSuccess) {
                          waitingForSegSubCreation = false;
                          BlocProvider.of<CoachRequestStreamBloc>(context).resolve(_coachRequest, _user.uid, RequestStatusEnum.resolved);
                          if (_wantsToCreateStory) {
                            StoryUtils.callBlocToCreateStory(context, state.segmentSubmission, totalScore, widget.segments[widget.segmentIndex]);
                          } else {
                            _isVideoUploaded = true;
                            _segmentSubmission = state?.segmentSubmission;
                          }
                        }
                      },
                      child: BlocListener<FriendBloc, FriendState>(
                          listener: (context, friendState) {
                            if (friendState is GetFriendsDataSuccess) {
                              _friends = friendState.friends;
                              if (!_progressCreated && _user != null) {
                                BlocProvider.of<UserProgressBloc>(context).create(
                                    _user.uid,
                                    SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) || SegmentUtils.isEMOM(widget.segments[widget.segmentIndex])
                                        ? 1
                                        : 0,
                                    _friends);
                                _progressCreated = true;
                              }
                            }
                          },
                          child: form()),
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget topSection() {
    return SizedBox(
      height: clockScreenProportion(true),
      child: BlocBuilder<CurrentTimeBloc, CurrentTimeState>(
        builder: (context, state) {
          if (state is CurrentTimeValue) {
            currentTime = state.timerTask;
          }
          return Padding(
              padding: EdgeInsets.only(
                  top: ScreenUtils.smallScreen(context)
                      ? 30
                      : ScreenUtils.mediumScreen(context)
                          ? 44
                          : 55),
              child: OrientationBuilder(builder: (context, orientation) {
                return orientatedClock();
              }));
        },
      ),
    );
  }

  Widget orientatedClock() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return getClock();
    } else {
      return RotationTransition(turns: AlwaysStoppedAnimation(90 / 360), child: getClock());
    }
  }

  Widget getClock() {
    return Clock(
      workState: workState,
      segments: widget.segments,
      segmentIndex: widget.segmentIndex,
      timerEntries: timerEntries,
      textController: textController,
      goToNextStep: _goToNextStep,
      actionAMRAP: actionAMRAP,
      setPaused: setPaused,
      workoutType: workoutType,
      timerTaskIndex: timerTaskIndex,
      timeLeft: currentTime ?? Duration(seconds: timerEntries[timerTaskIndex].value),
    );
  }

  Widget bottomSection() {
    return Container(
        decoration: BoxDecoration(
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        height: lowerSectionScreenProportion(true),
        child: OrientationBuilder(builder: (context, orientation) {
          return orientatedLowerSection();
        }));
  }

  Widget orientatedLowerSection() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return getLowerSection();
    } else {
      return RotationTransition(turns: AlwaysStoppedAnimation(90 / 360), child: getLowerSection());
    }
  }

  Widget getLowerSection() {
    return BlocBuilder<TimerTaskBloc, TimerTaskState>(
      builder: (context, timerTaskState) => ClocksLowerSection(
        areDiferentMovsWithRepCouter: _areDiferentMovsWithRepCouter,
        workState: workState,
        segments: widget.segments,
        segmentIndex: widget.segmentIndex,
        timerEntries: timerEntries,
        timerTaskIndex: timerTaskIndex,
        createStory: _createStory,
        workoutType: workoutType,
        originalWorkoutType: _recordingPaused ? workoutType : widget.workoutType,
        segmentSubmission: _segmentSubmission,
        scores: scores,
        totalScore: totalScore,
        counter: counter,
        isCameraReady: _isCameraReady,
        cameraController: cameraController,
        pauseButton: pauseButton(),
        classIndex: widget.classIndex,
        courseEnrollment: widget.courseEnrollment,
        segmentId: widget.segments[widget.segmentIndex].id,
        currentUser: currentUser,
        storyShared: timerTaskState is SetShareDone ? timerTaskState.shareDone : false,
        tooltipRemoteKey: personalRecordTooltipKey,
        movementAndWeightsForWorkout: (movementsAndWeights) {
          setState(() {
            movementsAndWeightsToSave = movementsAndWeights;
          });
        },
        segmentHasPersonalRecordMovement: (usePersonalRecord) {
          existPersonalRecordMovement = usePersonalRecord ?? false;
        },
      ),
    );
  }

  void resetAMRAPRound() {
    AMRAPRound = 0;
    BlocProvider.of<AmrapRoundBloc>(context).emitDefault();
  }

  void deleteUserProgress() {
    BlocProvider.of<UserProgressBloc>(context).delete(_user.uid, _friends);
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
    return Scaffold(
        extendBodyBehindAppBar: OlukoNeumorphism.isNeumorphismDesign,
        resizeToAvoidBottomInset: false,
        appBar: SegmentClocksUtils.getAppBar(context, setTopBarIcon(), isSegmentWithRecording(), workoutType, resetAMRAPRound, deleteUserProgress),
        backgroundColor: OlukoColors.black,
        body: scaffoldBody());
  }

  Widget scaffoldBody() {
    return (isSegmentWithRecording() && widget.showPanel)
        ? SlidingUpPanel(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(21), topRight: Radius.circular(21)),
            controller: recordingPanelController,
            minHeight: 0,
            maxHeight: 310,
            collapsed: Container(color: OlukoColors.black),
            panel: InitialTimerPanel(
              panelController: recordingPanelController,
              onShowAgainPressed: widget.onShowAgainPressed,
            ),
            body: bodyWithPlayPausePanel())
        : bodyWithPlayPausePanel();
  }

  Widget bodyWithPlayPausePanel() {
    return (isSegmentWithoutRecording() && (workState != WorkState.finished))
        ? SlidingUpPanel(
            controller: panelController,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            minHeight: 90.0,
            maxHeight: 185.0,
            collapsed: CollapsedMovementVideosSection(action: getPlayPauseAction()),
            panel: MovementVideosSection(
                action: getPlayPauseAction(),
                segment: widget.segments[widget.segmentIndex],
                onPressedMovement: () {
                  if (workState != WorkState.paused) {
                    changeSegmentState(navigateToMovement: true);
                  }
                }),
            body: _body(),
          )
        : _body();
  }

  Widget getPlayPauseAction() {
    return Padding(padding: const EdgeInsets.only(right: 10), child: OlukoNeumorphism.isNeumorphismDesign ? neumorphicPlayPauseAction() : playPauseAction());
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
          changeSegmentState();
        },
        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
      ),
    );
  }

  void changeSegmentState({bool navigateToMovement = false}) {
    final bool isCurrentTaskTimed = timerEntries[timerTaskIndex].parameter == ParameterEnum.duration;
    setState(() {
      if (isPlaying) {
        if (isSegmentWithoutRecording()) {
          panelController.open();
        }
        if (isCurrentTaskTimed) {
          BlocProvider.of<ClocksTimerBloc>(context).pauseCountdown(setPaused);
        } else {
          setPaused();
        }
        if (alertTimerPlaying) {
          alertTimer.cancel();
        }
        if (stopwatchTimer != null) {
          stopwatchTimer.cancel();
        }
      } else {
        if (isSegmentWithoutRecording()) {
          panelController.close();
        }
        workState = lastWorkStateBeforePause;
        if (isCurrentTaskTimed) {
          if (navigateToMovement) {
            setPaused();
          }
          BlocProvider.of<ClocksTimerBloc>(context).playCountdown(_goToNextStep, setPaused);
        } else {
          if (alertTimerPlaying) {
            _playAlert();
          }
        }
        _startStopwatch();
      }
      isPlaying = !isPlaying;
    });
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

  Widget _body() {
    if (recordingPanelController.isAttached && open) {
      recordingPanelController.open();
      open = false;
    }
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: Stack(children: [
        Column(
          children: [
            topSection(),
            bottomSection(),
          ],
        ),
        if (isWorkStateFinished())
          Positioned(
            bottom: 0,
            child: Container(
                color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
                height: ScreenUtils.height(context) * 0.14,
                width: ScreenUtils.width(context),
                child: SegmentClocksUtils.showButtonsWhenFinished(_recordingPaused ? workoutType : widget.workoutType, shareDone, context, shareDoneAction,
                    goToClassAction, nextSegmentAction, widget.segments, widget.segmentIndex, deleteUserProgress)),
          )
        else
          const SizedBox(),
        alertWidget()
      ]),
    );
  }

  Widget alertWidget() {
    if (alertTimerPlaying) {
      String alertText = _currentRoundAlerts[_alertIndex - 1].text;
      return Positioned(
        top: isSegmentWithoutRecording() ? ScreenUtils.height(context) * 0.59 : ScreenUtils.height(context) * 0.55,
        left: ScreenUtils.width(context) / 3.8,
        child: OlukoRoundAlert(text: alertText),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void shareDoneAction() {
    setState(() {
      shareDone = true;
    });
    BlocProvider.of<TimerTaskBloc>(context).setShareDone(shareDone);
  }

  Future<void> nextSegmentAction() async {
    BlocProvider.of<AnimationBloc>(context).playPauseAnimation();
    saveWorkoutMovementAndWeights();
    if (existPersonalRecordMovement) {
      if (getPersonalRecordMovement().isNotEmpty && getPersonalRecordMovement().first.weight != null) {
        await nextSegmentNavigation();
      }
    } else {
      await nextSegmentNavigation();
    }
  }

  Future<void> nextSegmentNavigation() async {
    if (widget.segmentIndex < widget.segments.length - 1) {
      Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.segmentDetail]));
      Navigator.popAndPushNamed(
        context,
        routeLabels[RouteEnum.segmentDetail],
        arguments: {
          'segmentIndex': widget.segmentIndex + 1,
          'classIndex': widget.classIndex,
          'courseEnrollment': widget.courseEnrollment,
          'courseIndex': widget.courseIndex,
          'fromChallenge': _isFromChallenge,
          'classSegments': widget.segments,
        },
      );
    } else {
      await _soundPlayer.playAsset(soundEnum: SoundsEnum.classFinished, headsetState: _headsetState, isForWatch: true);
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
    saveWorkoutMovementAndWeights();
    if (existPersonalRecordMovement) {
      if (getPersonalRecordMovement().isNotEmpty && getPersonalRecordMovement().first.weight != null) {
        goToClassNavigation();
      }
    } else {
      goToClassNavigation();
    }
  }

  void goToClassNavigation() {
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

    BlocProvider.of<AmrapRoundBloc>(context).set(AMRAPRound);

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
            stopVideo();
          });
        },
        child: SegmentClocksUtils.pauseButton());
  }

  void _goToSegmentDetail() {
    Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.segmentDetail]));
  }

  Future<void> stopVideo() async {
    if (isSegmentWithRecording()) {
      await cameraController.stopVideoRecording();
      BottomDialogUtils.showBottomDialog(
        context: context,
        content: PauseDialogContent(resumeAction: _resume, restartAction: _goToSegmentDetail),
      );
      _recordingPaused = true;
      workoutType = WorkoutType.segment;
      isPlaying = false;
    }
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

  bool isLastRestBeforeRecording() {
    int indexOfLastRest;
    TimerEntry lastRestEntry = timerEntries.lastWhere((timeEntry) => timeEntry.movement.isRestTime, orElse: () => null);
    if (lastRestEntry != null) {
      indexOfLastRest = timerEntries.indexOf(lastRestEntry);
      if (indexOfLastRest == timerEntries.length) {
        lastRestEntry = timerEntries.getRange(0, indexOfLastRest - 1).lastWhere((timeEntry) => timeEntry.movement.isRestTime, orElse: () => null);
        if (lastRestEntry != null) {
          indexOfLastRest = timerEntries.indexOf(lastRestEntry);
        }
      }
    }
    return indexOfLastRest != null ? timerTaskIndex == indexOfLastRest : false;
  }

  navigateToSegmentWithoutRecording() {
    TimerUtils.startCountdown(WorkoutType.segment, context, getArguments(), widget.segments[widget.segmentIndex].initialTimer);
    BlocProvider.of<CoachRequestStreamBloc>(context).resolve(_coachRequest, widget.courseEnrollment.userId, RequestStatusEnum.ignored);
  }

  Object getArguments() {
    return {
      'segmentIndex': widget.segmentIndex,
      'classIndex': widget.classIndex,
      'courseEnrollment': widget.courseEnrollment,
      'courseIndex': widget.courseIndex,
      'workoutType': WorkoutType.segment,
      'coach': widget.coach,
      'segments': widget.segments,
      'fromChallenge': widget.fromChallenge,
      'coachRequest': _coachRequest,
      'currentTaskIndex': realTaskIndex
    };
  }

  askForRecordSegment() {
    BottomDialogUtils.showBottomDialog(
      backgroundTapEnable: false,
      onDismissAction: () => _resume(),
      context: context,
      content: CoachRequestContent(
        name: widget.coach?.firstName ?? '',
        image: widget.coach?.avatar,
        onNotRecordingAction: () {
          Navigator.pop(context);
          _playTask();
        },
        onRecordingAction: navigateToSegmentWithRecording,
        isNotification: false,
      ),
    );
  }

  navigateToSegmentWithRecording() {
    Navigator.pushNamed(
      context,
      routeLabels[RouteEnum.segmentCameraPreview],
      arguments: {
        'segmentIndex': widget.segmentIndex,
        'classIndex': widget.classIndex,
        'coach': widget.coach,
        'courseEnrollment': widget.courseEnrollment,
        'courseIndex': widget.courseIndex,
        'segments': widget.segments,
        'currentTaskIndex': realTaskIndex
      },
    );
  }

  Future<void> _goToNextStep() async {
    if (alertTimer != null) {
      alertTimer.cancel();
    }
    alertTimerPlaying = false;

    if (!SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      if ((isLastOne() || nextIsFirstRound()) ||
          ((nextIsLastOne() && nextIsRestTime()) || (thereAreTwoMorePos() && nextIsRestTime() && twoPosLaterIsFirstRound()))) {
        _saveSegmentRound();
      }
    }

    _saveCounter();

    _saveStopwatch();

    if (timerTaskIndex == timerEntries.length - 1 && realTaskIndex <= timerEntries.length - 1) {
      _finishWorkout();
      realTaskIndex++;
      setState(() {});
      return;
    }
    if (timerTaskIndex < timerEntries.length - 1) {
      timerTaskIndex++;
    }

    realTaskIndex++;

    if (((timerTaskIndex - 1) == 0) || currentRoundDifferentToNextRound()) {
      setAlert();
      if (!SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && !SegmentUtils.isEMOM(widget.segments[widget.segmentIndex])) {
        BlocProvider.of<UserProgressBloc>(context)
            .update(_user.uid, timerEntries[timerTaskIndex].round / widget.segments[widget.segmentIndex].rounds, _friends);
      }
    }
    if ((isLastRestBeforeRecording() && !recordingNotificationIsShow) && widget.coachRequest != null) {
      await recordingNotification();
    } else if (widget.coachRequest != null && isLastOne()) {
      askForRecordSegment();
    } else {
      _playTask();
    }
    BlocProvider.of<TimerTaskBloc>(context).setTimerTaskIndex(timerTaskIndex);

    if (timerEntries[timerTaskIndex].stopwatch) {
      _startStopwatch();
    }
    BlocProvider.of<CurrentTimeBloc>(context).setCurrentTimeNull();

    if (isSegmentWithRecording() && timerTaskIndex == 1) {
      _setupCameras();
    }

    if (recordingPanelController.isAttached && timerTaskIndex == 1) {
      recordingPanelController.close();
    }

    if (timerEntries[timerTaskIndex].round != null && timerEntries[timerTaskIndex].round > 0) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        cameraController?.dispose();
      });
    }
  }

  Future<void> recordingNotification() async {
    setPaused();
    setState(() {
      recordingNotificationIsShow = true;
    });

    BottomDialogUtils.showBottomDialog(
      context: context,
      backgroundTapEnable: false,
      onDismissAction: () => _resume(),
      content: CoachRequestContent(
        name: widget.coach?.firstName ?? '',
        image: widget.coach?.avatar,
        onNotificationDismiss: () {
          setState(() {
            recordingNotificationIsShow = true;
          });
          Navigator.pop(context);
          _resume();
        },
        isNotification: true,
      ),
    );
    await _soundPlayer.playAsset(asset: _recordingNotificationSound, headsetState: _headsetState, isForWatch: true);
  }

  bool currentRoundDifferentToNextRound() {
    if (timerTaskIndex >= timerEntries.length) {
      return false;
    }
    if (timerEntries[timerTaskIndex - 1].round != timerEntries[timerTaskIndex].round) {
      return true;
    }
    return false;
  }

  _saveStopwatch() {
    if (timerEntries[timerTaskIndex].stopwatch &&
        (timerTaskIndex == timerEntries.length - 1 ||
            timerEntries[timerTaskIndex].sectionIndex < timerEntries[timerTaskIndex + 1].sectionIndex ||
            timerEntries[timerTaskIndex].round < timerEntries[timerTaskIndex + 1].round)) {
      int currentDuration = stopwatchDuration.inSeconds;
      durationPR += currentDuration;
      totalScore += currentDuration;
      scoresInt[timerEntries[timerTaskIndex].round] += currentDuration;
      scores[timerEntries[timerTaskIndex].round] = TimeConverter.durationToString(Duration(seconds: scoresInt[timerEntries[timerTaskIndex].round]));

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
    scoresInt[timerEntries[timerTaskIndex - 1].round] += int.parse(textController.text);
    scores[timerEntries[timerTaskIndex - 1].round] = scoresInt[timerEntries[timerTaskIndex - 1].round].toString() +
        ' ' +
        (_areDiferentMovsWithRepCouter ? 'reps' : timerEntries[timerTaskIndex - 1].movement.getLabel());
  }

  WorkState getCurrentTaskWorkState() {
    if (isCurrentMovementRest()) {
      return WorkState.resting;
    } else if (isInitialTimer()) {
      return WorkState.countdown;
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

  Future<void> _finishWorkout() async {
    if (!SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && !SegmentUtils.isEMOM(widget.segments[widget.segmentIndex])) {
      BlocProvider.of<UserProgressBloc>(context).update(_user.uid, 1, _friends);
    }

    if (alertTimer != null) {
      alertTimer.cancel();
    }

    workState = WorkState.finished;

    print('Workout finished');
    BlocProvider.of<PointsCardBloc>(context).updateCourseCompletionAndCheckNewCardCollected(widget.courseEnrollment, widget.segmentIndex, widget.classIndex);

    if (widget.segments[widget.segmentIndex].isChallenge && widget.segments[widget.segmentIndex].typeOfChallenge != ChallengeTypeEnum.Weight) {
      await personalRecordActions();
    }

    Wakelock.disable();
  }

  Future<void> personalRecordActions() async {
    await StoryUtils.createNewPRChallengeStory(context, getPersonalRecordValue(), _user.uid, widget.segments[widget.segmentIndex],
        isDurationRecord: isDurationRecord());
    BlocProvider.of<PersonalRecordBloc>(context).create(widget.segments[widget.segmentIndex], widget.courseEnrollment, getPersonalRecordValue(),
        SegmentUtils.getPersonalRecordParam(timerEntries[timerEntries.length - 1].counter, widget.segments[widget.segmentIndex]), widget.fromChallenge);
  }

  bool isDurationRecord() {
    return SegmentUtils.getPersonalRecordParam(timerEntries[timerEntries.length - 1].counter, widget.segments[widget.segmentIndex]) ==
        PersonalRecordParam.duration;
  }

  Widget setTopBarIcon() {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        if (state is VideoSuccess || state is VideoFailure) {
          return const SizedBox();
        } else {
          if (_segmentSubmission != null && widget.workoutType == WorkoutType.segmentWithRecording && !_isVideoUploaded) {
            return SegmentClocksUtils.uploadingIcon();
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }

  int getPersonalRecordValue() {
    int value;
    CounterEnum counter = timerEntries[timerEntries.length - 1].counter;
    if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      value = AMRAPRound;
    } else if (counter != CounterEnum.none) {
      value = totalScore;
    } else if (SegmentUtils.isWeightChallenge(widget.segments[widget.segmentIndex])) {
      value = movementsAndWeightsToSave.firstWhere((weightRecord) => weightRecord.isPersonalRecord).weight;
    } else {
      value = durationPR;
    }
    return value;
  }

  //Called each time round change
  void setAlert() {
    alertDuration = Duration.zero;
    _alertIndex = 0;
    List<RoundsAlerts> roundsAlerts = widget.segments[widget.segmentIndex].roundsAlerts;
    if (roundsAlerts != null && roundsAlerts.isNotEmpty) {
      if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
        _currentRoundAlerts = roundsAlerts[0].alerts;
      } else {
        _currentRoundAlerts = roundsAlerts[timerEntries[timerTaskIndex].round].alerts;
      }
      if (_currentRoundAlerts != null && _currentRoundAlerts.isNotEmpty) {
        _playAlert();
      }
    }
  }

  void _playAlert() {
    alertTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      checkNewAlertToShow();
      checkAlertReachedMaxDuration();
      checkNextAlertStartingBeforeCurrentOneFinished();
      alertDuration = Duration(seconds: alertDuration.inSeconds + 1);
    });
  }

  void checkNewAlertToShow() {
    int index;

    if (_isIndexInRange()) {
      index = _alertIndex;
    } else {
      if (_isIndexEqualToLength()) {
        index = _alertIndex - 1;
      } else {
        index = _alertIndex;
      }
    }

    if (_isIndexInRange(index)) {
      if (alertDuration.inSeconds == _currentRoundAlerts[index].time) {
        setState(() {
          alertTimerPlaying = true;
        });
        if (_canIncrementAlert()) {
          _alertIndex++;
        }
      }
    }
  }

  void checkAlertReachedMaxDuration() {
    int index;

    if (_isIndexInRange()) {
      if (_alertIndex == 0) {
        index = _alertIndex;
      } else {
        index = _alertIndex - 1;
      }
    } else {
      if (_isIndexEqualToLength()) {
        index = _alertIndex - 1;
      } else {
        index = _alertIndex;
      }
    }

    if (_isIndexInRange(index)) {
      int momentAlertStarted = _currentRoundAlerts[index].time;
      int currentAlertDuration = alertDuration.inSeconds - momentAlertStarted;
      if (currentAlertDuration == _alertTotalDuration) {
        setState(() {
          alertTimerPlaying = false;
        });
        if (_canIncrementAlert()) {
          _alertIndex++;
        }
      }
    }
  }

  void checkNextAlertStartingBeforeCurrentOneFinished() {
    if (_existsNextAlert()) {
      int nextAlertTime = _currentRoundAlerts[_alertIndex + 1].time;
      if (alertDuration.inSeconds == nextAlertTime) {
        _alertIndex++;
        return;
      }
    }
  }

  bool _canIncrementAlert() {
    return (_alertIndex + 1) <= _currentRoundAlerts.length;
  }

  bool _existsNextAlert() {
    return (_alertIndex + 1) < _currentRoundAlerts.length;
  }

  bool _isIndexInRange([int index]) {
    int i = index == null ? _alertIndex : index;
    return i < _currentRoundAlerts.length;
  }

  bool _isIndexEqualToLength() {
    return _alertIndex == _currentRoundAlerts.length;
  }

  _startMovement() {
    //Reset countdown variables
    timerTaskIndex = 0;
    timerEntries = SegmentUtils.getExercisesList(widget.segments[widget.segmentIndex]);
    _areDiferentMovsWithRepCouter = SegmentClocksUtils.diferentMovsWithRepCouter(timerEntries);
    if (timerEntries.isEmpty) {
      _finishWorkout();
      return;
    }
    if (timerEntries[0].stopwatch) {
      _startStopwatch();
      Wakelock.enable();
    }
    if (isSegmentWithRecording()) {
      _setupCameras();
      timerTaskIndex = widget.currentTaskIndex;
      workState = getCurrentTaskWorkState();
    } else {
      _playTask();
    }
  }

  void setPaused() {
    setState(() {
      if (workState != WorkState.paused) {
        lastWorkStateBeforePause = workState;
      }
      workState = WorkState.paused;
    });
  }

  @override
  void dispose() {
    //TODO: for screen rotation
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);*/
    Wakelock.disable();
    WidgetsBinding.instance.removeObserver(this);
    if (stopwatchTimer != null && stopwatchTimer.isActive) {
      stopwatchTimer.cancel();
    }
    if (alertTimer != null && alertTimer.isActive) {
      alertTimer.cancel();
    }
    cameraController?.dispose();
    _soundPlayer?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive) return;
    final isPausedInactive = state == AppLifecycleState.paused;
    if (isPausedInactive) {
      if (workState != WorkState.paused) {
        if (cameraController != null) {
          cameraController.pauseVideoRecording();
        }
      }
    } else {
      if (isSegmentWithRecording()) {
        if (cameraController != null) {
          try {
            await cameraController.resumeVideoRecording();
          } catch (e) {
            resetAMRAPRound();
            deleteUserProgress();
            SegmentClocksUtils.segmentClockOnWillPop(context);
          }
        }
        _resume();
      }
    }
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
      _isCameraReady = true;
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
    BlocProvider.of<SegmentSubmissionBloc>(context).create(_user, widget.courseEnrollment, widget.segments[widget.segmentIndex], videoRecorded.path,
        widget.coach != null ? widget.coach.id : null, widget.courseEnrollment.classes[widget.classIndex].id, _coachRequest);
  }

//STOPWATCH FUNCTIONS
  void _startStopwatch() {
    stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) => _addTime());
  }

  _addTime() {
    const int addSeconds = 1;
    final int seconds = (stopwatchDuration?.inSeconds ?? 0) + addSeconds;
    stopwatchDuration = Duration(seconds: seconds);
    BlocProvider.of<StopwatchBloc>(context)?.updateStopwatch(stopwatchDuration);
  }

  void _stopAndResetStopwatch() {
    stopwatchTimer?.cancel();
    stopwatchDuration = Duration();
    BlocProvider.of<StopwatchBloc>(context).updateStopwatch(stopwatchDuration);
  }

  void _resume() {
    setState(() {
      workState = isCurrentMovementRest() ? WorkState.resting : lastWorkStateBeforePause;
      BlocProvider.of<ClocksTimerBloc>(context).playCountdown(_goToNextStep, setPaused);
      isPlaying = true;
    });
  }

  bool isInitialTimer() {
    return timerEntries[timerTaskIndex].isInitialTimer != null && timerEntries[timerTaskIndex].isInitialTimer;
  }

  double clockScreenProportion(bool isHeight) {
    double screenProportion = isHeight ? ScreenUtils.height(context) : ScreenUtils.width(context);
    return getCurrentTaskWorkState() == WorkState.countdown
        ? screenProportion
        : isWorkStateFinished()
            ? screenProportion * 0.4
            : isSegmentWithoutRecording()
                ? screenProportion
                : screenProportion * 0.6;
  }

  double lowerSectionScreenProportion(bool isHeight) {
    double screenProportion = isHeight ? ScreenUtils.height(context) : ScreenUtils.width(context);
    return getCurrentTaskWorkState() == WorkState.countdown
        ? 0
        : isWorkStateFinished()
            ? screenProportion * 0.46
            : isSegmentWithoutRecording()
                ? 0
                : screenProportion * 0.4;
  }

  void saveWorkoutMovementAndWeights() {
    if (existPersonalRecordMovement && (getPersonalRecordMovement().isEmpty || getPersonalRecordMovement().first.weight == null)) {
      showTooltipForPR();
    } else {
      if (existPersonalRecordMovement && getPersonalRecordMovement().isNotEmpty) {
        personalRecordActions();
      }
    }
    if (movementsAndWeightsToSave.isNotEmpty) {
      if (movementSetMaxWeight()) {
        BlocProvider.of<MaxWeightsBloc>(context).setMaxWeightForSegmentMovements(currentUser.id, movementsAndWeightsToSave);
      }
      if (_segmentSubmission != null && existMovementsWithWeight()) {
        final List<WeightRecord> segmentSubmissionWeights = setWeightsForSubmission();
        BlocProvider.of<SegmentSubmissionBloc>(context).updateSubmissionWeights(_segmentSubmission, segmentSubmissionWeights);
      }
      BlocProvider.of<WorkoutWeightBloc>(context)
          .saveWeightToWorkout(currentCourseEnrollment: widget.courseEnrollment, workoutMovementsAndWeights: movementsAndWeightsToSave);
    }
  }

  void showTooltipForPR() {
    personalRecordTooltipKey.currentState?.ensureTooltipVisible();
  }

  List<WorkoutWeight> getPersonalRecordMovement() => movementsAndWeightsToSave.where((weightRecord) => weightRecord.isPersonalRecord).toList();

  bool movementSetMaxWeight() => movementsAndWeightsToSave.where((weightRecord) => weightRecord.setMaxWeight).isNotEmpty;

  List<WeightRecord> setWeightsForSubmission() {
    final List<WeightRecord> weightsToSave = [];

    movementsAndWeightsToSave.forEach((element) {
      final WeightRecord weight = WeightRecord(
        courseEnrollmentId: widget.courseEnrollment.id,
        sectionIndex: element.sectionIndex,
        movementIndex: element.movementIndex,
        movementId: element.movementId,
        weight: element.weight.toDouble(),
        segmentId: widget.segments[widget.segmentIndex].id,
        classId: widget.courseEnrollment.classes[widget.classIndex].id,
      );

      weightsToSave.add(weight);
    });

    return weightsToSave;
  }

  bool existMovementsWithWeight() => movementsAndWeightsToSave.where((record) => record.weight != null).toList().isNotEmpty;
}
