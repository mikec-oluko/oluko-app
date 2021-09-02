import 'dart:async';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/movement_submission_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/routes.dart';
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

class SegmentClocks extends StatefulWidget {
  final WorkoutType workoutType;
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int segmentIndex;
  final List<Segment> segments;

  SegmentClocks(
      {Key key,
      this.workoutType,
      this.classIndex,
      this.segmentIndex,
      this.courseEnrollment,
      this.segments})
      : super(key: key);

  @override
  _SegmentClocksState createState() => _SegmentClocksState();
}

class _SegmentClocksState extends State<SegmentClocks> {
  WorkoutType workoutType;
  Image movementVideoThumbnailImage = Image.asset(
    'assets/assessment/task_response_thumbnail.png',
    fit: BoxFit.cover,
  );
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
  List<Movement> _movements = [];

  bool isPlaying = true;

  PanelController panelController = new PanelController();

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
        return BlocBuilder<MovementBloc, MovementState>(
            builder: (context, movementState) {
          if (movementState is GetAllSuccess) {
            _movements = movementState.movements;
            return BlocListener<SegmentSubmissionBloc, SegmentSubmissionState>(
                listener: (context, segmentSubmissionState) {
                  if (segmentSubmissionState is CreateSuccess) {
                    _segmentSubmission =
                        segmentSubmissionState.segmentSubmission;
                  }
                },
                child: form());
          } else {
            return SizedBox();
          }
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
      bottomNavigationBar:
          widget.workoutType == WorkoutType.segmentWithRecording &&
                  workState == WorkState.paused
              ? resumeButton()
              : SizedBox(),
      appBar: OlukoAppBar(
        showDivider: false,
        title: ' ',
        actions: [topCameraIcon(), audioIcon()],
      ),
      backgroundColor: Colors.black,
      body: widget.workoutType == WorkoutType.segment &&
              workState != WorkState.finished
          ? SlidingUpPanel(
              controller: panelController,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              minHeight: 90,
              maxHeight: 185,
              collapsed: CollapsedMovementVideosSection(action: getAction()),
              panel: MovementVideosSection(
                  action: getAction(),
                  segment: widget.segments[widget.segmentIndex],
                  movements: _movements,
                  onPressedMovement:
                      (BuildContext context, Movement movement) =>
                          Navigator.pushNamed(
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
            bool isCurrentTaskTimed =
                this.timerEntries[timerTaskIndex].time != null;
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
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(12),
            shape: CircleBorder(),
            side: BorderSide(color: Colors.white),
          ),
        ));
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
                          context, routeLabels[RouteEnum.segmentClocks],
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
              TimerUtils.roundsTimer(
                  widget.segments[widget.segmentIndex].rounds,
                  timerEntries[timerTaskIndex].roundNumber),
              _countdownSection(workState)
            ])),
        workState == WorkState.finished ? SizedBox() : _tasksSection()
      ],
    ));
  }

  ///Current and next movement labels
  Widget _tasksSection() {
    String currentTask = timerEntries[timerTaskIndex].label;
    String nextTask = timerTaskIndex < timerEntries.length - 1
        ? timerEntries[timerTaskIndex + 1].label
        : '';
    return widget.workoutType == WorkoutType.segment
        ? taskSectionWithoutRecording(currentTask, nextTask)
        : recordingTaskSection(currentTask, nextTask);
  }

  Widget taskSectionWithoutRecording(String currentTask, String nextTask) {
    if (timerEntries[timerTaskIndex].label == null) {
      return Padding(
          padding: EdgeInsets.only(top: 25),
          child: Column(children: getJoinedLabel()));
    } else {
      return Padding(
          padding: EdgeInsets.only(top: 25),
          child: Column(
            children: [
              currentTaskWidget(currentTask),
              SizedBox(height: 10),
              nextTaskWidget(nextTask)
            ],
          ));
    }
  }

  List<Widget> getJoinedLabel() {
    List<Widget> labelWidgets = [];
    timerEntries[timerTaskIndex].labels.forEach((label) {
      labelWidgets.add(Text(label,
          style: TextStyle(
              fontSize: 20,
              color: OlukoColors.white,
              fontWeight: FontWeight.w300)));
      labelWidgets.add(Divider(
        height: 10,
        color: OlukoColors.divider,
        thickness: 0,
        indent: 0,
        endIndent: 0,
      ));
    });
    return labelWidgets;
  }

  Widget recordingTaskSection(String currentTask, String nextTask) {
    if (timerEntries[timerTaskIndex].label == null) {
      List<Widget> items = getJoinedLabel();
      return Container(
          height: 45,
          child: ListView(children: [
            Padding(
                padding: EdgeInsets.only(top: 10),
                child: Column(children: items))
          ]));
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
                            fontSize: 20,
                            color: OlukoColors.grayColorSemiTransparent,
                            fontWeight: FontWeight.bold),
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

    Duration actualTime =
        Duration(seconds: timerEntries[timerTaskIndex].time) - this.timeLeft;

    double circularProgressIndicatorValue =
        (actualTime.inSeconds / timerEntries[timerTaskIndex].time);

    if (workState == WorkState.paused) {
      return TimerUtils.pausedTimer(
          context, TimeConverter.durationToString(this.timeLeft));
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

  Widget currentTaskWidget(String currentTask, [bool smaller = false]) {
    return Text(
      currentTask,
      style: TextStyle(
          fontSize: smaller ? 20 : 25,
          color: Colors.white,
          fontWeight: FontWeight.bold),
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
        style: TextStyle(
            fontSize: 25,
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
              : SizedBox());
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
      ..markSegmentAsCompleated(
          widget.courseEnrollment, widget.segmentIndex, widget.classIndex);
    setState(() {});
  }

  _startMovement() {
    //Reset countdown variables
    timerTaskIndex = 0;
    this.timerEntries = SegmentUtils.getExercisesList(
        widget.segments[widget.segmentIndex], context);
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
              child: Icon(Icons.circle_outlined,
                  size: 12, color: OlukoColors.primary))
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
          _tasksSection(),
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
