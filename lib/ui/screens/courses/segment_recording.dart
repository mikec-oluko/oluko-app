import 'dart:async';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/movement_submission_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/movement_videos_action_enum.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/models/timer_model.dart';
import 'package:oluko_app/ui/IntervalProgressBarLib/interval_progress_bar.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/segment_progress.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum WorkoutType { segment, segmentWithRecording }

class SegmentRecording extends StatefulWidget {
  final WorkoutType workoutType;
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int segmentIndex;
  final List<Segment> segments;

  SegmentRecording(
      {Key key,
      this.workoutType,
      this.classIndex,
      this.segmentIndex,
      this.courseEnrollment,
      this.segments})
      : super(key: key);

  @override
  _SegmentRecordingState createState() => _SegmentRecordingState();
}

class _SegmentRecordingState extends State<SegmentRecording> {
  WorkoutType workoutType;

  //Imported from Timer POC Models
  WorkState workState = WorkState.initial;
  WorkState lastWorkStateBeforePause = WorkState.initial;

  //Current task running on Countdown Timer
  num timerTaskIndex = 0;
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
  bool isCameraFront = true;
  List<TimerEntry> timerEntries;

  User _user;
  SegmentSubmission _segmentSubmission;

  @override
  void initState() {
    _setupCameras();
    this.workoutType = widget.workoutType;
    _startMovement();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.firebaseUser;
        return BlocBuilder<SegmentBloc, SegmentState>(
            builder: (context, segmentState) {
          return BlocListener<SegmentSubmissionBloc, SegmentSubmissionState>(
              listener: (context, segmentState) {
                if (segmentState is CreateSuccess) {
                  _segmentSubmission = segmentState.segmentSubmission;
                }
              },
              child: form());
        });
      } else {
        return SizedBox();
      }
    });
  }

  form() {
    if (widget.workoutType == WorkoutType.segmentWithRecording &&
        _segmentSubmission == null) {
      BlocProvider.of<SegmentSubmissionBloc>(context)
        ..create(_user, widget.courseEnrollment,
            widget.segments[widget.segmentIndex]);
    }
    return Scaffold(
      appBar: OlukoAppBar(
        showDivider: false,
        title: ' ',
        actions: [topCameraIcon(), audioIcon()],
      ),
      backgroundColor: Colors.black,
      body: widget.workoutType == WorkoutType.segment
          ? SlidingUpPanel(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              minHeight: 90,
              maxHeight: 200,
              collapsed: CollapsedMovementVideosSection(
                  action: MovementVideosActionEnum.Up),
              panel: MovementVideosSection(),
              body: _body())
          : _body(),
    );
  }

  Widget _body() {
    return Container(
        child: Column(children: [
      _timerSection(this.workoutType, this.workState),
      _lowerSection(this.workoutType, this.workState)
    ]));
  }

  /*
  View Sections
  */

  ///Countdown & movements information
  Widget _timerSection(WorkoutType workoutType, WorkState workState) {
    return Center(
        child: Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 8),
            child: Stack(
                alignment: Alignment.center,
                children: [buildCircle(), _countdownSection(workState)])),
        _tasksSection(
            timerEntries[timerTaskIndex].label,
            timerTaskIndex < timerEntries.length - 1
                ? timerEntries[timerTaskIndex + 1].label
                : '')
      ],
    ));
  }

  ///Clock countdown label
  Widget _countdownSection(WorkState workState) {
    bool isTimedTask = timerEntries[timerTaskIndex].time != null;

    if (!isTimedTask) {
      return repsTimer();
    }

    Duration actualTime =
        Duration(seconds: timerEntries[timerTaskIndex].time) - this.timeLeft;

    double circularProgressIndicatorValue =
        (actualTime.inSeconds / timerEntries[timerTaskIndex].time);

    if (workState == WorkState.paused) {
      return pausedTimer(TimeConverter.durationToString(this.timeLeft));
    }

    if (workState == WorkState.repResting) {
      return restTimer(circularProgressIndicatorValue,
          TimeConverter.durationToString(this.timeLeft));
    }

    return timeTimer(circularProgressIndicatorValue,
        TimeConverter.durationToString(this.timeLeft));
  }

  ///Current and next movement labels
  Widget _tasksSection(String currentTask, String nextTask) {
    return widget.workoutType == WorkoutType.segment ||
            timerEntries[timerTaskIndex].workState == WorkState.repResting
        ? Padding(
            padding: EdgeInsets.only(top: 25),
            child: Column(
              children: [
                currentTaskWidget(currentTask),
                SizedBox(height: 10),
                nextTaskWidget(nextTask)
              ],
            ))
        : Padding(
            padding: EdgeInsets.only(top: 7, bottom: 15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                currentTaskWidget(currentTask, true),
                //Positioned(right: -50, child: nextTaskWidget(nextTask, true)),
              ],
            ));
  }

  Widget currentTaskWidget(String currentTask, [bool smaller = false]) {
    return Text(
      currentTask,
      style: TextStyle(
          fontSize: smaller ? 20 : 25,
          color: Colors.white,
          fontWeight: FontWeight.bold),
    );
  }

  Widget nextTaskWidget(String nextTask, [bool smaller = false]) {
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
        style: TextStyle(
            fontSize: smaller ? 20 : 25,
            color: Color.fromRGBO(255, 255, 255, 0.25),
            fontWeight: FontWeight.bold),
      ),
    );
  }

  ///Lower half of the view
  Widget _lowerSection(WorkoutType workoutType, WorkState workoutState) {
    return Container(
      color: Colors.black,
      child: workoutType == WorkoutType.segmentWithRecording
          ? _cameraSection()
          : _controlsSection(workoutState),
    );
  }

  ///Section with an Array of buttons to handle workout control from user
  Widget _controlsSection(WorkState workoutState) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: workoutState != WorkState.paused
            ? /*_onPlayingActions()*/ [SizedBox()]
            : _onPausedActions(),
      ),
    );
  }

  ///Camera recording section. Shows camera Input and start/stop buttons.
  Widget _cameraSection() {
    TimerEntry currentTimerEntry = timerEntries[timerTaskIndex];
    bool showCamera = currentTimerEntry.workState == WorkState.exercising;
    return showCamera
        ? SizedBox(
            height: ScreenUtils.height(context) / 2,
            child: Stack(
              children: [
                (!_isReady)
                    ? Container()
                    : Center(
                        child: AspectRatio(
                            aspectRatio: 3.0 / 4.0,
                            child: CameraPreview(cameraController))),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: pauseButton())),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            right: 20.0, left: 80.0, top: 20.0, bottom: 20.0),
                        child: _cameraButton(Icons.flip_camera_android,
                            onPressed: () {
                          setState(() {
                            isCameraFront = !isCameraFront;
                          });
                          _setupCameras();
                        }))),
              ],
            ))
        : SizedBox();
  }

  Widget pauseButton() {
    return GestureDetector(
        //TODO: Add pause action
        onTap: () {},
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

  /*List<Widget> _onPlayingActions() {
    bool isCurrentTaskTimed = this.timerEntries[timerTaskIndex].time != null;
    OlukoPrimaryButton mainButton = isCurrentTaskTimed
        ? OlukoPrimaryButton(
            color: Colors.white,
            title: OlukoLocalizations.of(context).find('pause').toUpperCase(),
            onPressed: () => this.setState(() {
              //_pauseCountdown();
            }),
            icon: Icon(Icons.pause),
          )
        : OlukoPrimaryButton(
            color: Colors.white,
            //TODO translate
            title: 'NEXT',
            onPressed: () => this.setState(() {
                  _goToNextStep();
                }),
            icon: Icon(Icons.fast_forward));

    return [
      mainButton,
    ];
  }*/

  List<Widget> _onPausedActions() {
    bool isCurrentTaskTimed = this.timerEntries[timerTaskIndex].time != null;
    return [
      OlukoPrimaryButton(
        color: Colors.white,
        onPressed: () => this.setState(() {
          this.workState = this.lastWorkStateBeforePause;
          if (isCurrentTaskTimed) {
            _playCountdown();
          }
        }),
        title:
            OlukoLocalizations.of(context).find('resumeWorkouts').toUpperCase(),
      ),
    ];
  }

  //Timer Functions
  _saveLastStep(TimerEntry timerEntry) async {
    if (widget.workoutType == WorkoutType.segmentWithRecording &&
        timerEntry.workState == WorkState.exercising) {
      XFile videopath = await cameraController.stopVideoRecording();
      BlocProvider.of<MovementSubmissionBloc>(context)
        ..create(_segmentSubmission, timerEntries[timerTaskIndex].movement,
            videopath.path);
    }
  }

  void _goToNextStep() {
    _saveLastStep(timerEntries[timerTaskIndex]);
    if (timerTaskIndex == timerEntries.length - 1) {
      _finishWorkout();
      return;
    }
    this.setState(() {
      timerTaskIndex++;
      _playTask();
    });
  }

  _playTask() async {
    workState = timerEntries[timerTaskIndex].workState;
    if (widget.workoutType == WorkoutType.segmentWithRecording &&
        timerEntries[timerTaskIndex].workState == WorkState.exercising) {
      if (timerTaskIndex > 0) {
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
      ..markSegmentAsCompleated(
          widget.courseEnrollment, widget.segmentIndex, widget.classIndex);
    if (widget.workoutType == WorkoutType.segmentWithRecording) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SegmentProgress(segmentSubmission: _segmentSubmission)));
    } else {
      if (widget.segmentIndex < widget.segments.length - 1) {
        /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SegmentDetail(
                    user: widget.user,
                    segments: widget.segments,
                    segmentIndex: widget.segmentIndex + 1,
                    classIndex: widget.classIndex,
                    courseEnrollment: widget.courseEnrollment)));*/
      } else {
        //TODO: Go to next class
        /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SegmentDetail(
                    user: widget.user,
                    segments: widget.segments,
                    segmentIndex: 0,
                    classIndex: widget.classIndex,
                    courseEnrollment: widget.courseEnrollment)));*/
        //ver lo de las clases porque no tengo la lista de clases
      }
    }
  }

  _startMovement() {
    //Reset countdown variables
    timerTaskIndex = 0;
    this.timerEntries =
        SegmentUtils.getExercisesList(widget.segments[widget.segmentIndex]);
    _playTask();
  }

  void _playCountdown() {
    if (timerTaskIndex == 0) {
      timeLeft = Duration(seconds: timerEntries[0].time);
    }
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

  void _pauseCountdown() {
    lastWorkStateBeforePause = workState;
    this.workState = WorkState.paused;
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

  //Camera Functions
  Future<void> _setupCameras() async {
    int cameraPos = isCameraFront ? 0 : 1;
    try {
      cameras = await availableCameras();
      cameraController =
          new CameraController(cameras[cameraPos], ResolutionPreset.medium);
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

  Widget audioIcon() {
    return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Image.asset(
          'assets/courses/audio_icon.png',
          scale: 4,
        ));
  }

  //timers
  Widget buildCircle() => IntervalProgressBar(
        direction: IntervalProgressDirection.circle,
        max: 8,
        progress: 2,
        intervalSize: 4,
        size: Size(200, 200),
        highlightColor: OlukoColors.primary,
        defaultColor: OlukoColors.grayColor,
        intervalColor: Colors.transparent,
        intervalHighlightColor: Colors.transparent,
        reverse: true,
        radius: 0,
        intervalDegrees: 5,
        strokeWith: 5,
      );

  Widget timeTimer(double progressValue, String duration) {
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      value: progressValue,
                      // color: OlukoColors.coral,
                      backgroundColor: OlukoColors.grayColor)),
              Text(duration,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))
            ])));
  }

  Widget preTimer(String type, int round) {
    return Stack(alignment: Alignment.center, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 98.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                value: 0.4,
                // color: OlukoColors.coral,
                backgroundColor: OlukoColors.grayColor)),
      ),
      Column(children: [
        Text("4",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: OlukoColors.coral)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Round   ",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(round.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))
        ]),
        SizedBox(height: 2),
        Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(type + " In",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)))
      ])
    ]);
  }

  Widget pausedTimer(String duration) {
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      value: 0,
                      // color: OlukoColors.skyblue,
                      backgroundColor: OlukoColors.grayColor)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("PAUSED",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: OlukoColors.skyblue)),
                SizedBox(height: 12),
                Text(duration,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
              ])
            ])));
  }

  Widget restTimer(double progressValue, String duration) {
    //double ellipseScale = 4.5;
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(alignment: Alignment.center, children: [
              /*Image.asset(
                'assets/courses/ellipse_1.png',
                scale: ellipseScale,
              ),
              Image.asset(
                'assets/courses/ellipse_2.png',
                scale: ellipseScale,
              ),
              Image.asset(
                'assets/courses/ellipse_3.png',
                scale: ellipseScale,
              ),*/
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      value: progressValue,
                      // color: OlukoColors.skyblue,
                      backgroundColor: OlukoColors.grayColor)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("REST",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: OlukoColors.skyblue)),
                SizedBox(height: 12),
                Text(duration,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
              ])
            ])));
  }

  Widget repsTimer() {
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: GestureDetector(
                onTap: () => this.setState(() {
                      _goToNextStep();
                    }),
                child: Stack(alignment: Alignment.center, children: [
                  AspectRatio(
                      aspectRatio: 1,
                      child: CircularProgressIndicator(
                          value: 0,
                          // color: OlukoColors.skyblue,
                          backgroundColor: OlukoColors.grayColor)),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Tap here",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: OlukoColors.primary)),
                        SizedBox(height: 5),
                        Text("when done",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: OlukoColors.primary))
                      ])
                ]))));
  }
}
