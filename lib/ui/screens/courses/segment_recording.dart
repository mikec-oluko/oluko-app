import 'dart:async';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/movement_submission_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/models/timer_model.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/screens/courses/segment_detail.dart';
import 'package:oluko_app/ui/screens/courses/segment_progress.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

enum WorkoutType { segment, segmentWithRecording }

class SegmentRecording extends StatefulWidget {
  final WorkoutType workoutType;
  final User user;
  final CourseEnrollment courseEnrollment;
  final List<Segment> segments;
  final int classIndex;
  final int segmentIndex;

  SegmentRecording(
      {Key key,
      this.workoutType,
      this.user,
      this.classIndex,
      this.segmentIndex,
      this.courseEnrollment,
      this.segments})
      : super(key: key);

  @override
  _SegmentRecordingState createState() => _SegmentRecordingState();
}

class _SegmentRecordingState extends State<SegmentRecording> {
  //Dynamic images
  String backgroundImage =
      'https://c0.wallpaperflare.com/preview/26/779/700/fitness-men-sports-gym.jpg';
  WorkoutType workoutType;
  //Used in 'Share' image
  Image movementVideoThumbnailImage = Image.asset(
    'assets/assessment/task_response_thumbnail.png',
    fit: BoxFit.cover,
  );

  //Imported from Timer POC Models
  TaskType taskType = TaskType.DEFAULT;
  TimerScreen timerScreen = TimerScreen.stop_watch;
  WorkState workState = WorkState.initial;
  WorkState lastWorkStateBeforePause = WorkState.initial;

  //Current task running on Countdown Timer
  num timerTaskIndex = 0;
  Duration timeLeft;

  // ---- End Make Dynamic ----

  final toolbarHeight = kToolbarHeight * 2;

  //Flex proportions to display sections vertically in body.
  List<num> flexProportions(WorkoutType workoutType) =>
      workoutType == WorkoutType.segmentWithRecording ? [3, 7] : [8, 2];
  Timer countdownTimer;
  //Camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  //Used to check if camera input is ready
  bool _isReady = false;
  bool isCameraFront = true;
  List<TimerEntry> timerEntries;

  SegmentSubmissionBloc _segmentSubmissionBloc;
  MovementSubmissionBloc _movementSubmissionBloc;
  SegmentSubmission segmentSubmission;
  MovementSubmission movementSubmission;
  CourseEnrollmentBloc _courseEnrollmentBloc;

  _startMovement() {
    //Reset countdown variables
    timerTaskIndex = 0;
    //Merge all movement exercises (Workouts & Rests) into a List iterable by the Timer
    this.timerEntries =
        _getExercisesList(widget.segments[widget.segmentIndex].rounds);
    _playTask(timerTaskIndex);
  }

  @override
  void initState() {
    _setupCameras();
    _startMovement();
    this.workoutType = widget.workoutType;
    _segmentSubmissionBloc = SegmentSubmissionBloc();
    _movementSubmissionBloc = MovementSubmissionBloc();
    _courseEnrollmentBloc = CourseEnrollmentBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<SegmentSubmissionBloc>(
            create: (context) => _segmentSubmissionBloc,
          ),
          BlocProvider<MovementSubmissionBloc>(
            create: (context) => _movementSubmissionBloc,
          ),
          BlocProvider<CourseEnrollmentBloc>(
            create: (context) => _courseEnrollmentBloc,
          )
        ],
        child: BlocListener<MovementSubmissionBloc, MovementSubmissionState>(
            listener: (context, movementState) {
              if (movementState is CreateMovementSubmissionSuccess) {
                movementSubmission = movementState.movementSubmission;
              }
            },
            child: BlocListener<SegmentSubmissionBloc, SegmentSubmissionState>(
                listener: (context, segmentState) {
                  if (segmentState is CreateSuccess) {
                    segmentSubmission = segmentState.segmentSubmission;
                  }
                },
                child: form())));
  }

  form() {
    if (widget.workoutType == WorkoutType.segmentWithRecording &&
        segmentSubmission == null) {
      _segmentSubmissionBloc
        ..create(widget.user, widget.courseEnrollment,
            widget.segments[widget.segmentIndex]);
    }
    return Scaffold(
      appBar: OlukoAppBar(
        title: ' ',
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.94), BlendMode.darken),
                fit: BoxFit.cover,
                image: NetworkImage(backgroundImage))),
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context) - toolbarHeight,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(
            //   flex: 8,
            //   child: _segmentInfoSection(),
            // ),
            // Expanded(
            //     flex: 2,
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Row(
            //         children: _onCompletedActions(),
            //       ),
            //     ))

            Expanded(
                flex: this.flexProportions(this.workoutType)[0],
                child: _timerSection(this.workoutType, this.workState)),
            Expanded(
                flex: this.flexProportions(this.workoutType)[1],
                child: _lowerSection(this.workoutType, this.workState))
          ]),
    );
  }

  /*
  View Sections
  */

  ///Countdown & movements information
  Widget _timerSection(WorkoutType workoutType, WorkState workState) {
    List<Widget> widgetsToShow = [
      Expanded(child: _countdownSection(workState)),
      Expanded(
          child: _tasksSection(
              timerEntries[timerTaskIndex].label,
              timerTaskIndex < timerEntries.length - 1
                  ? timerEntries[timerTaskIndex + 1].label
                  : ''))
    ];
    return workoutType == WorkoutType.segmentWithRecording
        ? Row(
            children: widgetsToShow,
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: widgetsToShow,
              ),
            ],
          );
  }

  ///Clock countdown label
  Widget _countdownSection(WorkState workState) {
    bool isTimedTask = timerEntries[timerTaskIndex].time != null;
    double circularProgressIndicatorValue = isTimedTask
        ? (this.timeLeft.inSeconds / timerEntries[timerTaskIndex].time)
        : 100;
    return Stack(fit: StackFit.loose, alignment: Alignment.center, children: [
      Padding(
        padding: const EdgeInsets.all(18.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                value: isTimedTask ? circularProgressIndicatorValue : 1)),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              isTimedTask
                  ? TimeConverter.durationToString(this.timeLeft)
                  : timerEntries[timerTaskIndex].reps.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          !isTimedTask ? MovementUtils.movementTitle('REPS') : SizedBox(),
          workState == WorkState.paused
              ? MovementUtils.movementTitle(
                  OlukoLocalizations.of(context).find('paused').toUpperCase())
              : SizedBox()
        ],
      )
    ]);
  }

  ///Current and next movement labels
  Widget _tasksSection(String currentTask, String nextTask) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentTask,
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          Text(
            nextTask,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          )
        ],
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
            ? _onPlayingActions()
            : _onPausedActions(),
      ),
    );
  }

  ///Camera recording section. Shows camera Input and start/stop buttons.
  Widget _cameraSection() {
    TimerEntry currentTimerEntry = timerEntries[timerTaskIndex];
    bool showCamera = currentTimerEntry.workState == WorkState.exercising;
    bool showNextButton = currentTimerEntry.reps != null &&
        currentTimerEntry.workState == WorkState.exercising;
    return Column(
      children: [
        Expanded(
          child: Container(
            child: showCamera
                ? Stack(
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
                              child: _feedbackButton(Icons.stop,
                                  onPressed:
                                      () async {} /*=> this.setState(() {
                                  this.workoutType = WorkoutType.segment;
                                })*/
                                  ))),
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 20.0,
                                  left: 80.0,
                                  top: 20.0,
                                  bottom: 20.0),
                              child: _cameraButton(Icons.flip_camera_android,
                                  onPressed: () {
                                setState(() {
                                  isCameraFront = !isCameraFront;
                                });
                                _setupCameras();
                              }))),
                      showNextButton
                          ? Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 200.0, top: 20.0, bottom: 20.0),
                                  child: _cameraButton(Icons.fast_forward,
                                      onPressed: () {
                                    setState(() {
                                      _goToNextStep();
                                    });
                                  })))
                          : SizedBox(),
                    ],
                  )
                : SizedBox(),
          ),
        ),
      ],
    );
  }

  ///Section with information about segment and workout movements.
  // ignore: unused_element
  Widget _segmentInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                MovementUtils.movementTitle(
                    widget.segments[widget.segmentIndex].name),
                _completedBadge()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MovementUtils.labelWithTitle(
                '${OlukoLocalizations.of(context).find('duration')}:',
                '${widget.segments[widget.segmentIndex].duration} Seconds'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MovementUtils.labelWithTitle(
                '${OlukoLocalizations.of(context).find('rounds')}:',
                '${widget.segments[widget.segmentIndex].rounds} ${OlukoLocalizations.of(context).find('rounds')}'),
          ),
          /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: MovementUtils.workout(tasks, context),
          ),*/
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: _shareCard(),
          ),
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

  /*
  Other Methods
  */

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

  Widget _cameraButton(IconData iconData, {Function() onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Icon(
        iconData,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _completedBadge() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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

  List<Widget> _onPlayingActions() {
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
  }

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

  // ignore: unused_element
  List<Widget> _onCompletedActions() {
    return [
      OlukoPrimaryButton(
          color: Colors.white,
          onPressed: () => this.setState(() {}),
          title:
              //TODO translate
              'GO TO CLASS' //OlukoLocalizations.of(context).find('goToClass').toUpperCase(),
          ),
      SizedBox(
        width: 25,
      ),
      OlukoPrimaryButton(
          color: Colors.white,
          onPressed: () => this.setState(() {}),
          title:
              //TODO translate
              'NEXT SEGMENT' //OlukoLocalizations.of(context).find('goToClass').toUpperCase(),
          ),
    ];
  }

  //Timer Functions
  _saveLastStep(TimerEntry timerEntry) async {
    if (widget.workoutType == WorkoutType.segmentWithRecording &&
        timerEntry.workState == WorkState.exercising) {
      XFile videopath = await cameraController.stopVideoRecording();
      _movementSubmissionBloc
        ..create(segmentSubmission, timerEntries[timerTaskIndex].movement,
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
      _playTask(timerTaskIndex);
    });
  }

  _playTask(num timerTaskIndex) async {
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
    _courseEnrollmentBloc
      ..markSegmentAsCompleated(
          widget.courseEnrollment, widget.segmentIndex, widget.classIndex);
    if (widget.workoutType == WorkoutType.segmentWithRecording) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SegmentProgress(segmentSubmission: segmentSubmission)));
    } else {
      if (widget.segmentIndex < widget.segments.length - 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SegmentDetail(
                    user: widget.user,
                    segments: widget.segments,
                    segmentIndex: widget.segmentIndex + 1,
                    classIndex: widget.classIndex,
                    courseEnrollment: widget.courseEnrollment)));
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

  ///Merge all movement Exercises (Workouts & Rests) taking into account Sets & Rounds. Returns an Exercise list consumible by the Timer.
  List<TimerEntry> _getExercisesList(num rounds) {
    List<TimerEntry> entries = [];
    for (var roundIndex = 0; roundIndex < rounds; roundIndex++) {
      for (var movementIndex = 0;
          movementIndex < widget.segments[widget.segmentIndex].movements.length;
          movementIndex++) {
        for (var setIndex = 0;
            setIndex <
                widget.segments[widget.segmentIndex].movements[movementIndex]
                    .timerSets;
            setIndex++) {
          bool isTimedEntry = widget.segments[widget.segmentIndex]
                  .movements[movementIndex].timerWorkTime !=
              null;
          bool isLastMovement = movementIndex ==
              widget.segments[widget.segmentIndex].movements.length - 1;
          //Add work entry
          entries.add(TimerEntry(
              time: widget.segments[widget.segmentIndex]
                  .movements[movementIndex].timerWorkTime,
              reps: widget.segments[widget.segmentIndex]
                  .movements[movementIndex].timerReps,
              movement:
                  widget.segments[widget.segmentIndex].movements[movementIndex],
              setNumber: setIndex,
              roundNumber: roundIndex,
              label:
                  '${isTimedEntry ? widget.segments[widget.segmentIndex].movements[movementIndex].timerWorkTime : widget.segments[widget.segmentIndex].movements[movementIndex].timerReps} ${isTimedEntry ? 'Sec' : 'Reps'} ${widget.segments[widget.segmentIndex].movements[movementIndex].name}',
              workState: WorkState.exercising));
          //Add rest entry
          entries.add(TimerEntry(
              time: isLastMovement
                  ? widget.segments[widget.segmentIndex].roundBreakDuration
                  : widget.segments[widget.segmentIndex]
                      .movements[movementIndex].timerRestTime,
              movement:
                  widget.segments[widget.segmentIndex].movements[movementIndex],
              setNumber: setIndex,
              roundNumber: roundIndex,
              label:
                  '${isLastMovement ? widget.segments[widget.segmentIndex].roundBreakDuration : widget.segments[widget.segmentIndex].movements[movementIndex].timerRestTime} Sec rest',
              workState: WorkState.repResting));
        }
      }
    }
    return entries;
  }

  @override
  void dispose() {
    if (this.countdownTimer != null && this.countdownTimer.isActive) {
      this.countdownTimer.cancel();
    }
    cameraController?.dispose();
    super.dispose();
  }

  /*
  Camera Functions
  */

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
}
