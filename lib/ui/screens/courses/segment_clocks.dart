import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_update_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/feedback_card.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/share_card.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/timer_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum WorkoutType { segment, segmentWithRecording }

class SegmentClocks extends StatefulWidget {
  final WorkoutType workoutType;
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int segmentIndex;
  final List<Segment> segments;

  SegmentClocks({Key key, this.workoutType, this.classIndex, this.segmentIndex, this.courseEnrollment, this.segments}) : super(key: key);

  @override
  _SegmentClocksState createState() => _SegmentClocksState();
}

class _SegmentClocksState extends State<SegmentClocks> {
  //Imported from Timer POC Models
  WorkState workState;
  WorkState lastWorkStateBeforePause;

  //Current task running on Countdown Timer
  int timerTaskIndex = 0;
  Duration timeLeft;
  Timer countdownTimer;

  final toolbarHeight = kToolbarHeight * 2;

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
  PanelController panelController = new PanelController();
  TextEditingController textController = new TextEditingController();
  int AMRAPRound = 0;
  Widget topBarIcon;
  String processPhase = "";
  double progress = 0.0;
  bool isThereError = false;
  bool shareDone = false;

  WorkoutType workoutType;

  List<String> scores = [];
  int totalScore = 0;
  bool counter = false;

  @override
  void initState() {
    workoutType = widget.workoutType;
    if (isSegmentWithRecording()) {
      _setupCameras();
    }
    _startMovement();
    topBarIcon = SizedBox();
    if (widget.segments[widget.segmentIndex].rounds != null) {
      scores =
          List<String>.filled(widget.segments[widget.segmentIndex].rounds, "-");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.firebaseUser;
        return BlocBuilder<MovementBloc, MovementState>(builder: (context, movementState) {
          if (movementState is GetAllSuccess) {
            _movements = movementState.movements;
            return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: BlocListener<VideoBloc, VideoState>(
                    listener: (context, state) {
                      updateSegment(state);
                    },
                    child: BlocListener<SegmentSubmissionBloc, SegmentSubmissionState>(
                        listener: (context, state) {
                          if (state is CreateSuccess) {
                            if (_segmentSubmission == null) {
                              _segmentSubmission = state.segmentSubmission;
                              BlocProvider.of<VideoBloc>(context)
                                ..createVideo(context, File(_segmentSubmission.videoState.stateInfo), 3.0 / 4.0, _segmentSubmission.id);
                            }
                          }
                        },
                        child: form())));
          } else {
            return SizedBox();
          }
        });
      } else {
        return SizedBox();
      }
    });
  }

  bool isSegmentWithRecording() {
    return workoutType == WorkoutType.segmentWithRecording;
  }

  Widget form() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: OlukoAppBar(
        showDivider: false,
        title: ' ',
        showBackButton: false,
        actions: [topBarIcon, audioIcon()],
      ),
      backgroundColor: Colors.black,
      body: isSegmentWithoutRecording() && workState != WorkState.finished
          ? SlidingUpPanel(
              controller: panelController,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              minHeight: 90,
              maxHeight: 185,
              collapsed: CollapsedMovementVideosSection(action: getAction()),
              panel: MovementVideosSection(
                  action: getAction(),
                  segment: widget.segments[widget.segmentIndex],
                  movements: _movements,
                  onPressedMovement: (BuildContext context, Movement movement) =>
                      Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement})),
              body: _body())
          : _body(),
    );
  }

  bool isSegmentWithoutRecording() {
    return workoutType == WorkoutType.segment;
  }

  Widget getAction() {
    return Padding(
        padding: EdgeInsets.only(right: 10),
        child: OutlinedButton(
          onPressed: () {
            bool isCurrentTaskTimed = timerEntries[timerTaskIndex].parameter == ParameterEnum.duration;
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
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(12),
            shape: CircleBorder(),
            side: BorderSide(color: Colors.white),
          ),
        ));
  }

  Widget _body() {
    return Container(
        child: ListView(
      children: [
        _timerSection(),
        _lowerSection(),
        isWorkStateFinished() ? showFinishedButtons() : SizedBox(),
      ],
    ));
  }

  Widget showFinishedButtons() {
    if (widget.workoutType == WorkoutType.segmentWithRecording && !shareDone) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.of(context).find('done'),
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
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OlukoOutlinedButton(
                title: OlukoLocalizations.of(context).find('goToClass'),
                thinPadding: true,
                onPressed: () => Navigator.pushNamed(
                        context, routeLabels[RouteEnum.insideClass],
                        arguments: {
                          'courseEnrollment': widget.courseEnrollment,
                          'classIndex': widget.classIndex
                        })),
            SizedBox(
              width: 15,
            ),
            OlukoPrimaryButton(
              title: OlukoLocalizations.of(context).find('nextSegment'),
              thinPadding: true,
              onPressed: () {
                widget.segmentIndex < widget.segments.length - 1
                    ? Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
                        'segmentIndex': widget.segmentIndex + 1,
                        'classIndex': widget.classIndex,
                        'courseEnrollment': widget.courseEnrollment,
                      })
                    : Navigator.pushNamed(context, routeLabels[RouteEnum.completedClass], arguments: {
                        'classIndex': widget.classIndex,
                        'courseEnrollment': widget.courseEnrollment,
                      });
              },
            ),
          ],
        ),
      );
    }
  }

  ///Countdown & movements information
  Widget _timerSection() {
    return Center(
        child: Column(
      children: [
        getSegmentLabel(),
        Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 8),
            child: Stack(alignment: Alignment.center, children: [getRoundsTimer(), _countdownSection()])),
        isWorkStateFinished() ? SizedBox() : _tasksSection()
      ],
    ));
  }

  bool isWorkStateFinished() {
    return workState == WorkState.finished;
  }

  bool isWorkStatePaused() {
    return workState == WorkState.paused;
  }

  Widget getSegmentLabel() {
    if (isWorkStateFinished()) {
      return SizedBox();
    }

    if (SegmentUtils.isEMOM(widget.segments[widget.segmentIndex])) {
      return TimerUtils.getRoundLabel(timerEntries[timerTaskIndex].round);
    } else if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      return TimerUtils.getRoundLabel(AMRAPRound);
    } else {
      return SizedBox();
    }
  }

  Widget getRoundsTimer() {
    if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && isWorkStateFinished()) {
      return TimerUtils.roundsTimer(AMRAPRound, AMRAPRound + 1);
    } else if (isWorkStateFinished()) {
      return TimerUtils.roundsTimer(widget.segments[widget.segmentIndex].rounds, widget.segments[widget.segmentIndex].rounds + 1);
    } else if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      return TimerUtils.roundsTimer(AMRAPRound + 1, AMRAPRound);
    } else {
      return TimerUtils.roundsTimer(widget.segments[widget.segmentIndex].rounds, timerEntries[timerTaskIndex].round);
    }
  }

  ///Current and next movement labels
  Widget _tasksSection() {
    return isSegmentWithoutRecording()
        ? taskSectionWithoutRecording()
        : Column(children: [SizedBox(height: 10), recordingTaskSection(), counterTextField(), SizedBox(height: 20)]);
  }

  Widget taskSectionWithoutRecording() {
    bool hasMultipleLabels = timerEntries[timerTaskIndex].labels.length > 1;
    if (hasMultipleLabels) {
      return Padding(padding: EdgeInsets.only(top: 25), child: Column(children: SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels)));
    } else {
      String currentTask = timerEntries[timerTaskIndex].labels[0];
      String nextTask = timerTaskIndex < timerEntries.length - 1 ? timerEntries[timerTaskIndex + 1].labels[0] : '';
      return Padding(
          padding: EdgeInsets.only(top: 25),
          child: Column(
            children: [currentTaskWidget(currentTask), SizedBox(height: 10), nextTaskWidget(nextTask), SizedBox(height: 15), counterTextField()],
          ));
    }
  }

  Widget counterTextField() {
    if (isCurrentMovementRest() &&
        (timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps || timerEntries[timerTaskIndex - 1].counter == CounterEnum.distance)) {
      return getTextField();
    } else {
      return SizedBox();
    }
  }

  Widget getTextField() {
    bool isCounterByReps = timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps;
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/courses/gray_background.png'),
          fit: BoxFit.cover,
        )),
        height: 50,
        child: Row(children: [
          SizedBox(width: 20),
          Text(OlukoLocalizations.of(context).find('enterScore'),
              style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300)),
          SizedBox(width: 10),
          SizedBox(
              width: isCounterByReps ? 40 : 70,
              child: TextField(
                controller: textController,
                style: TextStyle(fontSize: 20, color: OlukoColors.white, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
              )),
          SizedBox(width: 10),
          isCounterByReps
              ? Text(timerEntries[timerTaskIndex - 1].movement.name,
                  style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300))
              : Text(OlukoLocalizations.of(context).find('meters'),
                  style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300)),
        ]));
  }

  Widget recordingTaskSection() {
    bool hasMultipleLabels = timerEntries[timerTaskIndex].labels.length > 1;
    if (hasMultipleLabels) {
      List<Widget> items = SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels);
      return Container(height: 45, child: ListView(children: [Padding(padding: EdgeInsets.only(top: 10), child: Column(children: items))]));
    } else {
      String currentTask = timerEntries[timerTaskIndex].labels[0];
      String nextTask = timerTaskIndex < timerEntries.length - 1 ? timerEntries[timerTaskIndex + 1].labels[0] : '';
      return Container(
          width: ScreenUtils.width(context),
          child: Padding(
              padding: EdgeInsets.only(top: 7, bottom: 15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  currentTaskWidget(currentTask, true),
                  Positioned(
                      left: ScreenUtils.width(context) - 70,
                      child: Text(
                        nextTask,
                        style: TextStyle(fontSize: 20, color: OlukoColors.grayColorSemiTransparent, fontWeight: FontWeight.bold),
                      )),
                ],
              )));
    }
  }

  ///Clock countdown label
  Widget _countdownSection() {
    if (isWorkStateFinished()) {
      return TimerUtils.completedTimer(context);
    }

    if (!isWorkStatePaused() && isCurrentTaskByReps()) {
      return TimerUtils.repsTimer(
          () => setState(() {
                _goToNextStep();
              }),
          context);
    }

    if (isWorkStatePaused() && isCurrentTaskByReps()) {
      return TimerUtils.pausedTimer(context);
    }

    Duration actualTime = Duration(seconds: timerEntries[timerTaskIndex].value) - timeLeft;

    double circularProgressIndicatorValue = (actualTime.inSeconds / timerEntries[timerTaskIndex].value);

    if (isWorkStatePaused()) {
      return TimerUtils.pausedTimer(context, TimeConverter.durationToString(timeLeft));
    }

    //TODO: Fix end round timer
    /*if (isTimedTask && actualTime.inSeconds <= 5) {
      TimerUtils.initialTimer(
          InitialTimerType.End,
          timerEntries[timerTaskIndex].roundNumber + 1,
          5,
          timeLeft.inSeconds,
          context);
    }*/

    if (workState == WorkState.resting) {
      return TimerUtils.restTimer(circularProgressIndicatorValue, TimeConverter.durationToString(timeLeft), context);
    }

    if (timerEntries[timerTaskIndex].round == null) {
      //is AMRAP
      return TimerUtils.AMRAPTimer(circularProgressIndicatorValue, TimeConverter.durationToString(timeLeft), context, () {
        setState(() {
          AMRAPRound++;
        });
        if (AMRAPRound == 1) {
          _saveSegmentRound(timerEntries[timerTaskIndex]);
        }
      });
    }
    String counter = timerEntries[timerTaskIndex].counter == CounterEnum.reps ? timerEntries[timerTaskIndex].movement.name : null;
    return TimerUtils.timeTimer(circularProgressIndicatorValue, TimeConverter.durationToString(timeLeft), context, counter);
  }

  Widget currentTaskWidget(String currentTask, [bool smaller = false]) {
    return Text(
      currentTask,
      style: TextStyle(fontSize: smaller ? 20 : 25, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  Widget nextTaskWidget(String nextTask) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: Text(
        nextTask,
        style: TextStyle(fontSize: 25, color: Color.fromRGBO(255, 255, 255, 0.25), fontWeight: FontWeight.bold),
      ),
    );
  }

  ///Lower half of the view
  Widget _lowerSection() {
    if (workState != WorkState.finished) {
      return Container(color: Colors.black, child: isSegmentWithRecording() ? _cameraSection() : SizedBox());
    } else {
      return _segmentInfoSection();
    }
  }

  ///Camera recording section. Shows camera Input and start/stop buttons.
  Widget _cameraSection() {
    return isWorkStatePaused()
        ? SizedBox()
        : SizedBox(
            height: ScreenUtils.height(context) / 2,
            width: ScreenUtils.width(context),
            child: Stack(
              children: [
                (!_isReady)
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage('assets/courses/camera_background.png'),
                          fit: BoxFit.cover,
                        )),
                        child: Center(child: AspectRatio(aspectRatio: 3.0 / 4.0, child: CameraPreview(cameraController)))),
                Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.all(20.0), child: pauseButton())),
              ],
            ));
  }

  bool isCurrentTaskTimed() {
    return timerEntries[timerTaskIndex].parameter == ParameterEnum.duration;
  }

  bool isCurrentTaskByReps() {
    return timerEntries[timerTaskIndex].parameter == ParameterEnum.reps;
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
            XFile videopath = await cameraController.stopVideoRecording();
          }
          setState(() {
            workoutType = WorkoutType.segment;
            isPlaying = false;
          });
        },
        child: Stack(alignment: Alignment.center, children: [
          Image.asset(
            'assets/courses/oval.png',
            scale: 4,
          ),
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.asset(
                'assets/courses/center_oval.png',
                scale: 4,
              )),
          Image.asset(
            'assets/courses/pause_button.png',
            scale: 4,
          ),
        ]));
  }

  Widget _cameraButton(IconData iconData, {Function() onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Icon(
        iconData,
        color: OlukoColors.primary,
        size: 30,
      ),
    );
  }

  //Timer Functions
  _saveSegmentRound(TimerEntry timerEntry) async {
    if (isSegmentWithRecording()) {
      XFile videopath = await cameraController.stopVideoRecording();
      setState(() {
        workoutType = WorkoutType.segment;
      });
      BlocProvider.of<SegmentSubmissionBloc>(context)..create(_user, widget.courseEnrollment, widget.segments[widget.segmentIndex], videopath.path);
    }
  }

  void _goToNextStep() {
    if (!SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && timerEntries[timerTaskIndex].round == 0) {
      if (timerTaskIndex == timerEntries.length || timerEntries[timerTaskIndex + 1].round == 1) {
        _saveSegmentRound(timerEntries[timerTaskIndex]);
      }
    }

    _saveCounter();

    if (timerTaskIndex == timerEntries.length - 1) {
      _finishWorkout();
      return;
    }
    setState(() {
      timerTaskIndex++;
      _playTask();
    });
  }

  _saveCounter() {
    if (isCurrentMovementRest() && timerEntries[timerTaskIndex - 1].movement.counter != null && textController.text != "") {
      setState(() {
        counter = true;
      });

      addScoreEntry();

      BlocProvider.of<CourseEnrollmentUpdateBloc>(context)
        ..saveMovementCounter(
            widget.courseEnrollment,
            widget.segmentIndex,
            timerEntries[timerTaskIndex - 1].sectionIndex,
            widget.classIndex,
            timerEntries[timerTaskIndex - 1].movement,
            widget.segments[widget.segmentIndex].rounds,
            timerEntries[timerTaskIndex - 1].round,
            int.parse(textController.text));
    }
    textController.clear();
  }

  addScoreEntry() {
    setState(() {
      totalScore += int.parse(textController.text);
    });
    scores[timerEntries[timerTaskIndex - 1].round] = textController.text + " ";
    if (timerEntries[timerTaskIndex - 1].movement.counter == CounterEnum.distance) {
      scores[timerEntries[timerTaskIndex - 1].round] += 'm';
    } else {
      scores[timerEntries[timerTaskIndex - 1].round] += timerEntries[timerTaskIndex - 1].movement.name;
    }
  }

  WorkState getCurrentTaskWorkState() {
    if (isCurrentMovementRest()) {
      return WorkState.resting;
    } else {
      return WorkState.exercising;
    }
  }

  _playTask() async {
    WorkState previousWorkState = workState;
    workState = getCurrentTaskWorkState();
    if (isCurrentTaskTimed()) {
      _playCountdown();
      timeLeft = Duration(seconds: timerEntries[timerTaskIndex].value);
    }
  }

  void _finishWorkout() {
    workState = WorkState.finished;

    print('Workout finished');
    BlocProvider.of<CourseEnrollmentBloc>(context)..markSegmentAsCompleated(widget.courseEnrollment, widget.segmentIndex, widget.classIndex);
    setState(() {
      if (_segmentSubmission != null && widget.workoutType == WorkoutType.segmentWithRecording) {
        topBarIcon = uploadingIcon();
      }
    });
  }

  _startMovement() {
    //Reset countdown variables
    timerTaskIndex = 0;
    timerEntries = SegmentUtils.getExercisesList(widget.segments[widget.segmentIndex]);
    _playTask();
  }

  void _playCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (timeLeft.inSeconds == 0) {
        _pauseCountdown();
        _goToNextStep();
        return;
      }
      setState(() {
        timeLeft = Duration(seconds: timeLeft.inSeconds - 1);
      });
    });
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
    if (countdownTimer != null && countdownTimer.isActive) {
      countdownTimer.cancel();
    }
    cameraController?.dispose();
    super.dispose();
  }

  //Camera functions
  Future<void> _setupCameras() async {
    int cameraPos = isCameraFront ? 0 : 1;
    try {
      cameras = await availableCameras();
      cameraController = new CameraController(cameras[cameraPos], ResolutionPreset.medium);
      await cameraController.initialize();
      await cameraController.startVideoRecording();
    } on CameraException catch (_) {}
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

//App bar icons
  Widget topCameraIcon() {
    return Padding(
        padding: EdgeInsets.only(right: 5),
        child: Stack(alignment: Alignment.center, children: [
          Image.asset(
            'assets/courses/outlined_camera.png',
            scale: 4,
          ),
          Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.circle_outlined, size: 12, color: OlukoColors.primary))
        ]));
  }

  Widget uploadingIcon() {
    return Padding(
        padding: EdgeInsets.only(right: 2),
        child: GestureDetector(
            onTap: () {}/*=> BottomDialogUtils.showBottomDialog(
                context: context, content: dialogContainer())*/,
            child: Row(children: [
              Text(
                "Uploading",
                style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.w400),
                textAlign: TextAlign.start,
              ),
              SizedBox(width: 4),
              Icon(Icons.upload, color: Colors.white)
            ])));
  }

  Widget audioIcon() {
    return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Image.asset(
          'assets/courses/audio_icon.png',
          scale: 4,
        ));
  }

  ///Section with information about segment and workout movements.
  Widget _segmentInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovementUtils.movementTitle(widget.segments[widget.segmentIndex].name),
              ],
            ),
          ),
          SizedBox(height: 5),
          counter
              ? Column(crossAxisAlignment: CrossAxisAlignment.center, children: getScoresByRound())
              : Column(children: SegmentUtils.getWorkouts(widget.segments[widget.segmentIndex], OlukoColors.grayColor)),
          SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: widget.workoutType == WorkoutType.segment || shareDone
                  ? FeedbackCard()
                  : ShareCard()),
        ],
      ),
    );
  }

  List<Widget> getScoresByRound() {
    bool isCounterByReps = timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps;
    List<Widget> widgets = [];
    String totalText = OlukoLocalizations.of(context).find('total') + ": " + totalScore.toString() + " ";
    if (isCounterByReps) {
      totalText += timerEntries[timerTaskIndex - 1].movement.name;
    } else {
      totalText += OlukoLocalizations.of(context).find('meters');
    }

    widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(totalText, style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.primary)),
    ]));

    widgets.add(SizedBox(height: 15));
    for (int i = 0; i < scores.length; i++) {
      widgets.add(Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(OlukoLocalizations.of(context).find('round') + " " + (i + 1).toString(),
                style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.white)),
            Container(width: 60),
            Container(
                width: 50,
                child: Text(scores[i],
                    textAlign: TextAlign.end, style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400, customColor: OlukoColors.white)))
          ])));
    }
    return widgets;
  }

  void updateSegment(VideoState state) {
    if (state is VideoProcessing) {
      updateProgress(state);
    } else if (state is VideoEncoded) {
      saveEncodedState(state);
    } else if (state is VideoSuccess || state is VideoFailure) {
      if (state is VideoSuccess) {
        saveUploadedState(state);
        showSegmentMessage();
        setState(() {
          topBarIcon = SizedBox();
        });
      } else if (state is VideoFailure) {
        saveErrorState(state);
      }
    }
  }

  void saveEncodedState(VideoEncoded state) {
    setState(() {
      _segmentSubmission.videoState.state = SubmissionStateEnum.encoded;
      _segmentSubmission.videoState.stateInfo = state.encodedFilesDir;
      _segmentSubmission.video = state.video;
      _segmentSubmission.videoState.stateExtraInfo = state.thumbFilePath;
    });
    BlocProvider.of<SegmentSubmissionBloc>(context)..updateStateToEncoded(_segmentSubmission);
  }

  void saveUploadedState(VideoSuccess state) {
    setState(() {
      processPhase = OlukoLocalizations.of(context).find('completed');
      progress = 1.0;
      _segmentSubmission.video = state.video;
    });
    BlocProvider.of<SegmentSubmissionBloc>(context)..updateVideo(_segmentSubmission);
  }

  void saveErrorState(VideoFailure state) {
    setState(() {
      isThereError = true;
      _segmentSubmission.videoState.error = state.exceptionMessage;
    });
    BlocProvider.of<SegmentSubmissionBloc>(context)..updateStateToError(_segmentSubmission);
  }

  void showSegmentMessage() {
    String message;
    if (isThereError) {
      message = OlukoLocalizations.of(context).find('uploadedWithErrors');
    } else {
      message = OlukoLocalizations.of(context).find('segmentUploadedSuccessfully');
    }
    AppMessages.showSnackbar(context, message);
  }

  void updateProgress(VideoProcessing state) {
    setState(() {
      processPhase = state.processPhase;
      progress = state.progress;
    });
  }

  Widget dialogContainer() {
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/courses/dialog_background.png"),
            fit: BoxFit.cover,
          )),
          child: Column(children: [
            SizedBox(height: 20),
            SizedBox(height: 10),
            Padding(padding: const EdgeInsets.all(40.0), child: ProgressBar(processPhase: processPhase, progress: progress)),
          ])),
      Align(alignment: Alignment.topRight, child: IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))
    ]);
  }
}
