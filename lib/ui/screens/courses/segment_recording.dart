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
import 'package:oluko_app/models/utils/timer_model.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/IntervalProgressBarLib/interval_progress_bar.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/segment_detail.dart';
import 'package:oluko_app/ui/screens/courses/segment_progress.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/timer_utils.dart';
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
  Image movementVideoThumbnailImage = Image.asset(
    'assets/assessment/task_response_thumbnail.png',
    fit: BoxFit.cover,
  );
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
  bool isCameraFront = false;
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
      body: widget.workoutType == WorkoutType.segment &&
              workState != WorkState.finished
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
        child: Column(
      children: [
        _timerSection(this.workoutType, this.workState),
        Expanded(child: _lowerSection(this.workoutType, this.workState)),
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OlukoOutlinedButton(
                  title: 'Go To Class',
                  onPressed: () => Navigator.popUntil(context,
                      ModalRoute.withName(routeLabels[RouteEnum.insideClass]))),
              SizedBox(
                width: 15,
              ),
              OlukoPrimaryButton(
                title: 'Next Segment',
                onPressed: () {
                  widget.segmentIndex < widget.segments.length - 1
                      ? Navigator.pushNamed(
                          context, routeLabels[RouteEnum.segmentRecording],
                          arguments: {
                              'segmentIndex': widget.segmentIndex + 1,
                              'classIndex': widget.classIndex,
                              'courseEnrollment': widget.courseEnrollment,
                              'workoutType': workoutType,
                              'segments': widget.segments,
                            })
                      : Navigator.popUntil(
                          context,
                          ModalRoute.withName(
                              routeLabels[RouteEnum.insideClass]));
                },
              ),
            ],
          ),
        ),
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
        Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 8),
            child: Stack(alignment: Alignment.center, children: [
              //TODO: Make dynamic
              TimerUtils.roundsTimer(8, 2),
              _countdownSection(workState)
            ])),
        workState == WorkState.finished
            ? SizedBox()
            : _tasksSection(
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
      return TimerUtils.repsTimer(
          () => this.setState(() {
                _goToNextStep();
              }),
          context);
    }

    Duration actualTime =
        Duration(seconds: timerEntries[timerTaskIndex].time) - this.timeLeft;

    double circularProgressIndicatorValue =
        (actualTime.inSeconds / timerEntries[timerTaskIndex].time);

    if (workState == WorkState.paused) {
      return TimerUtils.pausedTimer(
          TimeConverter.durationToString(this.timeLeft), context);
    }

    if (workState == WorkState.repResting) {
      return TimerUtils.restTimer(circularProgressIndicatorValue,
          TimeConverter.durationToString(this.timeLeft), context);
    }

    if (workState == WorkState.finished) {
      return TimerUtils.completedTimer(circularProgressIndicatorValue,
          TimeConverter.durationToString(this.timeLeft));
    }

    return TimerUtils.timeTimer(circularProgressIndicatorValue,
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
    if (workoutState != WorkState.finished) {
      return Container(
        color: Colors.black,
        child: workoutType == WorkoutType.segmentWithRecording
            ? _cameraSection()
            : _controlsSection(workoutState),
      );
    } else {
      return _segmentInfoSection();
    }
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
            width: ScreenUtils.width(context),
            child: Stack(
              children: [
                (!_isReady)
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(
                              'assets/courses/camera_background.png'),
                          fit: BoxFit.cover,
                        )),
                        child: Center(
                            child: AspectRatio(
                                aspectRatio: 3.0 / 4.0,
                                child: CameraPreview(cameraController)))),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: pauseButton())),
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
    setState(() {});
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

  ///Section with information about segment and workout movements.
  // ignore: unused_element
  Widget _segmentInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //_completedBadge(),
                MovementUtils.movementTitle(
                    widget.segments[widget.segmentIndex].name),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: MovementUtils.labelWithTitle(
          //       '${OlukoLocalizations.of(context).find('duration')}:',
          //       '${widget.segments[widget.segmentIndex].duration} Seconds'),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: MovementUtils.labelWithTitle(
          //       '${OlukoLocalizations.of(context).find('rounds')}:',
          //       '${widget.segments[widget.segmentIndex].rounds} ${OlukoLocalizations.of(context).find('rounds')}'),
          // ),
          /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: MovementUtils.workout(tasks, context),
          ),*/
          _tasksSection(
              timerEntries[timerTaskIndex].label,
              timerTaskIndex < timerEntries.length - 1
                  ? timerEntries[timerTaskIndex + 1].label
                  : ''),
          Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: workoutType == WorkoutType.segment
                  ? _feedbackCard()
                  : _shareCard()),
        ],
      ),
    );
  }

  ///Information card with sharing options for the recorded video
  Widget _shareCard() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: OlukoColors.listGrayColor),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            movementVideoThumbnailImage,
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 0),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              OlukoLocalizations.of(context)
                                  .find('shareYourVideo'),
                              style: OlukoFonts.olukoBigFont(),
                              textAlign: TextAlign.start,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: Icon(Icons.movie),
                                        style: ElevatedButton.styleFrom(
                                            minimumSize: Size(50, 50),
                                            primary: Colors.white),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Stories',
                                            style:
                                                OlukoFonts.olukoMediumFont()),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: Icon(Icons.send),
                                        style: ElevatedButton.styleFrom(
                                            minimumSize: Size(50, 50),
                                            primary: Colors.white),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('To Coach',
                                            style:
                                                OlukoFonts.olukoMediumFont()),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Information card with Feedback Options
  // ignore: unused_element
  Widget _feedbackCard() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: OlukoColors.listGrayColor),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                OlukoLocalizations.of(context).find('howWasYourWorkoutSession'),
                style: OlukoFonts.olukoBigFont(),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    children: [_feedbackButton(Icons.favorite)],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [_feedbackButton(Icons.close)],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _feedbackButton(IconData iconData, {Function() onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Icon(iconData, color: Colors.white),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(15),
        shape: CircleBorder(),
        side: BorderSide(color: Colors.white),
      ),
    );
  }

  Widget _completedBadge() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: OlukoColors.listGrayColor,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        padding: EdgeInsets.all(5),
        child: Text(
          'COMPLETED',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /*
  Other Methods
  */

}
