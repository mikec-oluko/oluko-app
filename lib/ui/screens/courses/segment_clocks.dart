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
import 'package:oluko_app/blocs/movement_submission_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/enums/timer_type_enum.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/counter.dart';
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

  SegmentClocks({Key key, this.workoutType, this.classIndex, this.segmentIndex, this.courseEnrollment, this.segments})
      : super(key: key);

  @override
  _SegmentClocksState createState() => _SegmentClocksState();
}

class _SegmentClocksState extends State<SegmentClocks> {
  WorkoutType workoutType;

  //Imported from Timer POC Models
  WorkState workState = WorkState.initial;
  WorkState lastWorkStateBeforePause = WorkState.initial;

  //Current task running on Countdown Timer
  int timerTaskIndex = 0;
  Duration timeLeft;
  Timer countdownTimer;

  final toolbarHeight = kToolbarHeight * 2;

  //Flex proportions to display sections vertically in body.
  List<num> flexProportions(WorkoutType workoutType) =>
      workoutType == WorkoutType.segmentWithRecording ? [3, 7] : [8, 2];

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

  int currentMovementSubmission = 1;
  int totalMovementSubmissions;
  List<MovementSubmission> _movementSubmissions;
  String processPhase = "";
  double progress = 0.0;
  bool isThereError = false;

  @override
  void initState() {
    _setupCameras();
    this.workoutType = widget.workoutType;
    _startMovement();
    topBarIcon = topCameraIcon();
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
            return BlocListener<SegmentSubmissionBloc, SegmentSubmissionState>(
                listener: (context, segmentSubmissionState) {
                  if (segmentSubmissionState is CreateSuccess) {
                    _segmentSubmission = segmentSubmissionState.segmentSubmission;
                  }
                },
                child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: BlocListener<VideoBloc, VideoState>(
                        listener: (context, state) {
                          saveMovement(state);
                        },
                        child: BlocListener<MovementSubmissionBloc, MovementSubmissionState>(
                            listener: (context, state) {
                              if (state is GetMovementSubmissionSuccess) {
                                if (_movementSubmissions == null) {
                                  totalMovementSubmissions = state.movementSubmissions.length;
                                  _movementSubmissions = state.movementSubmissions;
                                  processMovementSubmission();
                                }
                              }
                            },
                            child: form()))));
          } else {
            return SizedBox();
          }
        });
      } else {
        return SizedBox();
      }
    });
  }

  Widget form() {
    if (widget.workoutType == WorkoutType.segmentWithRecording && _segmentSubmission == null) {
      BlocProvider.of<SegmentSubmissionBloc>(context)
        ..create(_user, widget.courseEnrollment, widget.segments[widget.segmentIndex]);
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: widget.workoutType == WorkoutType.segmentWithRecording && workState == WorkState.paused
          ? resumeButton()
          : SizedBox(),
      appBar: OlukoAppBar(
        showDivider: false,
        title: ' ',
        actions: [topBarIcon, audioIcon()],
      ),
      backgroundColor: Colors.black,
      body: widget.workoutType == WorkoutType.segment && workState != WorkState.finished
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
                  onPressedMovement: (BuildContext context, Movement movement) => Navigator.pushNamed(
                      context, routeLabels[RouteEnum.movementIntro],
                      arguments: {'movement': movement})),
              body: _body())
          : _body(),
    );
  }

  Widget getAction() {
    return Padding(
        padding: EdgeInsets.only(right: 10),
        child: OutlinedButton(
          onPressed: () {
            bool isCurrentTaskTimed = this.timerEntries[timerTaskIndex].time != null;
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
                this.workState = this.lastWorkStateBeforePause;
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
        _timerSection(this.workoutType, this.workState),
        _lowerSection(this.workoutType, this.workState),
        workState == WorkState.finished
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OlukoOutlinedButton(
                        title: 'Go To Class',
                        thinPadding: true,
                        onPressed: () =>
                            Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.insideClass]))),
                    SizedBox(
                      width: 15,
                    ),
                    OlukoPrimaryButton(
                      title: 'Next Segment',
                      thinPadding: true,
                      onPressed: () {
                        widget.segmentIndex < widget.segments.length - 1
                            ? Navigator.pushNamed(context, routeLabels[RouteEnum.segmentClocks], arguments: {
                                'segmentIndex': widget.segmentIndex + 1,
                                'classIndex': widget.classIndex,
                                'courseEnrollment': widget.courseEnrollment,
                                'workoutType': workoutType,
                                'segments': widget.segments,
                              })
                            : Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.insideClass]));
                      },
                    ),
                  ],
                ),
              )
            : SizedBox(),
      ],
    ));
  }

  /*
  View Sections
  */

  ///Countdown & movements information
  Widget _timerSection(WorkoutType workoutType, WorkState workState) {
    return Center(
        child: Column(
      children: [
        widget.segments[widget.segmentIndex].timerType == TimerTypeEnum.EMOM
            ? TimerUtils.getRoundLabel(timerEntries[timerTaskIndex].roundNumber)
            : SizedBox(),
        widget.segments[widget.segmentIndex].timerType == TimerTypeEnum.AMRAP
            ? TimerUtils.getRoundLabel(AMRAPRound)
            : SizedBox(),
        Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 8),
            child: Stack(alignment: Alignment.center, children: [getRoundsTimer(), _countdownSection(workState)])),
        workState == WorkState.finished ? SizedBox() : _tasksSection()
      ],
    ));
  }

  Widget getRoundsTimer() {
    if (workState == WorkState.finished) {
      return TimerUtils.roundsTimer(
          widget.segments[widget.segmentIndex].rounds, widget.segments[widget.segmentIndex].rounds + 1);
    } else if (widget.segments[widget.segmentIndex].timerType != TimerTypeEnum.AMRAP) {
      return TimerUtils.roundsTimer(
          widget.segments[widget.segmentIndex].rounds, timerEntries[timerTaskIndex].roundNumber);
    } else {
      TimerUtils.roundsTimer(AMRAPRound + 1, AMRAPRound);
    }
  }

  ///Current and next movement labels
  Widget _tasksSection() {
    String currentTask = timerEntries[timerTaskIndex].label;
    String nextTask = timerTaskIndex < timerEntries.length - 1 ? timerEntries[timerTaskIndex + 1].label : '';
    return widget.workoutType == WorkoutType.segment
        ? taskSectionWithoutRecording(currentTask, nextTask)
        : recordingTaskSection(currentTask, nextTask);
  }

  Widget taskSectionWithoutRecording(String currentTask, String nextTask) {
    if (timerEntries[timerTaskIndex].label == null) {
      return Padding(
          padding: EdgeInsets.only(top: 25),
          child: Column(children: SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels)));
    } else {
      return Padding(
          padding: EdgeInsets.only(top: 25),
          child: Column(
            children: [
              currentTaskWidget(currentTask),
              SizedBox(height: 10),
              nextTaskWidget(nextTask),
              SizedBox(height: 15),
              timerEntries[timerTaskIndex].workState == WorkState.resting &&
                      (timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps ||
                          timerEntries[timerTaskIndex - 1].counter == CounterEnum.distance)
                  ? getTextField()
                  : SizedBox()
            ],
          ));
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
              ? Text(timerEntries[timerTaskIndex].movement.name,
                  style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300))
              : Text(OlukoLocalizations.of(context).find('meters'),
                  style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300)),
        ]));
  }

  Widget recordingTaskSection(String currentTask, String nextTask) {
    if (timerEntries[timerTaskIndex].label == null) {
      List<Widget> items = SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels);
      return Container(
          height: 45,
          child: ListView(children: [Padding(padding: EdgeInsets.only(top: 10), child: Column(children: items))]));
    } else {
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
                        style: TextStyle(
                            fontSize: 20, color: OlukoColors.grayColorSemiTransparent, fontWeight: FontWeight.bold),
                      )),
                ],
              )));
    }
  }

  ///Clock countdown label
  Widget _countdownSection(WorkState workState) {
    bool isRepsTask = timerEntries[timerTaskIndex].reps != null;
    bool isTimedTask = timerEntries[timerTaskIndex].time != null;

    if (workState != WorkState.paused && isRepsTask) {
      return TimerUtils.repsTimer(
          () => this.setState(() {
                _goToNextStep();
              }),
          context);
    }

    if (workState == WorkState.paused && isRepsTask) {
      return TimerUtils.pausedTimer(context);
    }

    Duration actualTime = Duration(seconds: timerEntries[timerTaskIndex].time) - this.timeLeft;

    double circularProgressIndicatorValue = (actualTime.inSeconds / timerEntries[timerTaskIndex].time);

    if (workState == WorkState.finished) {
      return TimerUtils.completedTimer(
          circularProgressIndicatorValue, TimeConverter.durationToString(this.timeLeft), context);
    }

    if (workState == WorkState.paused) {
      return TimerUtils.pausedTimer(context, TimeConverter.durationToString(this.timeLeft));
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
      return TimerUtils.restTimer(
          circularProgressIndicatorValue, TimeConverter.durationToString(this.timeLeft), context);
    }

    if (timerEntries[timerTaskIndex].roundNumber == null) {
      //is AMRAP
      return TimerUtils.AMRAPTimer(
          circularProgressIndicatorValue,
          TimeConverter.durationToString(this.timeLeft),
          context,
          () => this.setState(() {
                AMRAPRound++;
              }));
    }

    String counter =
        timerEntries[timerTaskIndex].counter == CounterEnum.reps ? timerEntries[timerTaskIndex].movement.name : null;

    return TimerUtils.timeTimer(
        circularProgressIndicatorValue, TimeConverter.durationToString(this.timeLeft), context, counter);
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
  Widget _lowerSection(WorkoutType workoutType, WorkState workoutState) {
    if (workoutState != WorkState.finished) {
      return Container(
          color: Colors.black, child: workoutType == WorkoutType.segmentWithRecording ? _cameraSection() : SizedBox());
    } else {
      return _segmentInfoSection();
    }
  }

  Widget resumeButton() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          OlukoPrimaryButton(
              title: OlukoLocalizations.of(context).find('resume'),
              onPressed: () {
                this.setState(() {
                  _playTask();
                });
              })
        ]));
  }

  ///Camera recording section. Shows camera Input and start/stop buttons.
  Widget _cameraSection() {
    return workState == WorkState.paused
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
                        child:
                            Center(child: AspectRatio(aspectRatio: 3.0 / 4.0, child: CameraPreview(cameraController)))),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(padding: const EdgeInsets.all(20.0), child: pauseButton())),
              ],
            ));
  }

  Widget pauseButton() {
    bool isCurrentTaskTimed = this.timerEntries[timerTaskIndex].time != null;
    return GestureDetector(
        onTap: () async {
          if (timerEntries[timerTaskIndex].workState == WorkState.exercising) {
            await cameraController.stopVideoRecording();
          }
          setState(() {
            if (isCurrentTaskTimed) {
              _pauseCountdown();
            } else {
              setPaused();
            }
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
  _saveLastStep(TimerEntry timerEntry) async {
    if (widget.workoutType == WorkoutType.segmentWithRecording && timerEntry.workState == WorkState.exercising) {
      XFile videopath = await cameraController.stopVideoRecording();
      BlocProvider.of<MovementSubmissionBloc>(context)
        ..create(_segmentSubmission, timerEntries[timerTaskIndex].movement, videopath.path);
    }
  }

  void _goToNextStep() {
    _saveLastStep(timerEntries[timerTaskIndex]);

    _saveCounter();

    if (timerTaskIndex == timerEntries.length - 1) {
      _finishWorkout();
      return;
    }
    this.setState(() {
      timerTaskIndex++;
      _playTask();
    });
  }

  _saveCounter() {
    if (timerEntries[timerTaskIndex].workState == WorkState.resting &&
        timerEntries[timerTaskIndex].movement.counter != null &&
        textController.text != "") {
      Counter counter = Counter(
          round: timerEntries[timerTaskIndex].roundNumber,
          set: timerEntries[timerTaskIndex].setNumber,
          counter: int.parse(textController.text));
      BlocProvider.of<CourseEnrollmentUpdateBloc>(context)
        ..saveMovementCounter(widget.courseEnrollment, widget.segmentIndex, widget.classIndex,
            timerEntries[timerTaskIndex].movement, counter);
    }
    textController.clear();
  }

  _playTask() async {
    WorkState previousWorkState = workState;
    workState = timerEntries[timerTaskIndex].workState;
    if (widget.workoutType == WorkoutType.segmentWithRecording &&
        timerEntries[timerTaskIndex].workState == WorkState.exercising) {
      if (timerTaskIndex > 0 || previousWorkState == WorkState.paused) {
        await cameraController.startVideoRecording();
      }
    }
    if (timerEntries[timerTaskIndex].time != null) {
      _playCountdown();
      timeLeft = Duration(seconds: timerEntries[timerTaskIndex].time);
    }
  }

  void _finishWorkout() {
    workState = WorkState.finished;
    print('Workout finished');
    BlocProvider.of<CourseEnrollmentBloc>(context)
      ..markSegmentAsCompleated(widget.courseEnrollment, widget.segmentIndex, widget.classIndex);
    setState(() {
      if (widget.workoutType == WorkoutType.segmentWithRecording) {
        topBarIcon = uploadingIcon();
      }
    });
    BlocProvider.of<MovementSubmissionBloc>(context)..get(_segmentSubmission);
  }

  _startMovement() {
    //Reset countdown variables
    timerTaskIndex = 0;
    this.timerEntries = SegmentUtils.getExercisesList(widget.segments[widget.segmentIndex], context);
    _playTask();
  }

  void _playCountdown() {
    /*if (timerTaskIndex == 0) {
      timeLeft = Duration(seconds: timerEntries[0].time);
    }*/
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (timeLeft.inSeconds == 0) {
        _pauseCountdown();
        _goToNextStep();
        return;
      }
      this.setState(() {
        timeLeft = Duration(seconds: timeLeft.inSeconds - 1);
      });
    });
  }

  void setPaused() {
    lastWorkStateBeforePause = workState;
    this.workState = WorkState.paused;
  }

  void _pauseCountdown() {
    setPaused();
    countdownTimer.cancel();
  }

  @override
  void dispose() {
    if (this.countdownTimer != null && this.countdownTimer.isActive) {
      this.countdownTimer.cancel();
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
          Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.circle, size: 12, color: OlukoColors.primary))
        ]));
  }

  Widget uploadingIcon() {
    return Padding(
        padding: EdgeInsets.only(right: 2),
        child: GestureDetector(
            onTap: () => BottomDialogUtils.showBottomDialog(context: context, content: dialogContainer()),
            child: Row(children: [
              Text(
                "Uploading",
                style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.w400),
                textAlign: TextAlign.start,
              ),
              SizedBox(width: 4),
              Icon(Icons.upload_file, color: Colors.white)
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
          SizedBox(height: 15),
          Column(children: SegmentUtils.getJoinedMovements(widget.segments[widget.segmentIndex], context)),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: workoutType == WorkoutType.segment ? FeedbackCard() : ShareCard()),
        ],
      ),
    );
  }

  //video uploading methods

  processMovementSubmission() {
    MovementSubmission movementSubmission = _movementSubmissions[currentMovementSubmission - 1];
    BlocProvider.of<VideoBloc>(context)
      ..createVideo(context, File(movementSubmission.videoState.stateInfo), 3.0 / 4.0, movementSubmission.id);
  }

  void saveMovement(VideoState state) {
    MovementSubmission ms = _movementSubmissions[currentMovementSubmission - 1];
    if (state is VideoProcessing) {
      updateProgress(state);
    } else if (state is VideoEncoded) {
      saveEncodedState(state, ms);
    } else if (state is VideoSuccess || state is VideoFailure) {
      if (state is VideoSuccess) {
        saveUploadedState(state, ms);
      } else if (state is VideoFailure) {
        saveErrorState(state, ms);
      }
      if (currentMovementSubmission < totalMovementSubmissions) {
        setState(() {
          currentMovementSubmission++;
        });
        processMovementSubmission();
      } else {
        showSegmentMessage();
      }
    }
  }

  void saveEncodedState(VideoEncoded state, MovementSubmission ms) {
    setState(() {
      ms.videoState.state = SubmissionStateEnum.encoded;
      ms.videoState.stateInfo = state.encodedFilesDir;
      ms.video = state.video;
      ms.videoState.stateExtraInfo = state.thumbFilePath;
    });
    BlocProvider.of<MovementSubmissionBloc>(context)..updateStateToEncoded(ms);
  }

  void saveUploadedState(VideoSuccess state, MovementSubmission ms) {
    setState(() {
      processPhase = OlukoLocalizations.of(context).find('completed');
      progress = 1.0;
      ms.video = state.video;
    });
    BlocProvider.of<MovementSubmissionBloc>(context)..updateVideo(ms);
  }

  void saveErrorState(VideoFailure state, MovementSubmission ms) {
    setState(() {
      isThereError = true;
      ms.videoState.error = state.exceptionMessage;
    });
    BlocProvider.of<MovementSubmissionBloc>(context)..updateStateToError(ms);
  }

  void showSegmentMessage() {
    String message;
    if (isThereError) {
      message = OlukoLocalizations.of(context).find('uploadedWithErrors');
    } else {
      message = OlukoLocalizations.of(context).find('uploadedSuccessfully');
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
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: totalMovementSubmissions != null
                  ? Text(
                      OlukoLocalizations.of(context).find('processingVideo') +
                          " " +
                          currentMovementSubmission.toString() +
                          OlukoLocalizations.of(context).find('outOf') +
                          totalMovementSubmissions.toString(),
                      style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.white),
                    )
                  : SizedBox(),
            ),
            SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.all(40.0),
                child: ProgressBar(processPhase: processPhase, progress: progress)),
          ])),
      Align(
          alignment: Alignment.topRight,
          child: IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))
    ]);
  }
}
