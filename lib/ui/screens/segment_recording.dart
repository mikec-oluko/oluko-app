import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

enum WorkoutType { segment, segmentWithRecording }
enum WorkoutState { pause, playing }

class SegmentRecording extends StatefulWidget {
  final WorkoutType workoutType;

  SegmentRecording({Key key, this.workoutType}) : super(key: key);

  @override
  _SegmentRecordingState createState() => _SegmentRecordingState();
}

class _SegmentRecordingState extends State<SegmentRecording> {
  //TODO Make Dynamic
  Duration movementDuration = Duration(seconds: 35);
  Duration timeLeft = Duration(seconds: 35);
  List<String> tasks = ['30 Sec air squats', '30 Sec rest'];
  String segmentName = 'Intense Airsquats';
  num rounds = 8;
  String backgroundImage =
      'https://c0.wallpaperflare.com/preview/26/779/700/fitness-men-sports-gym.jpg';
  WorkoutType workoutType;
  WorkoutState workoutState = WorkoutState.playing;
  //Used in 'Share' image
  Image movementVideoThumbnailImage = Image.asset(
    'assets/assessment/task_response_thumbnail.png',
    fit: BoxFit.cover,
  );
  // ----

  final toolbarHeight = kToolbarHeight * 2;

  //Flex proportions to display sections vertically in body.
  List<num> flexProportions(WorkoutType workoutType) =>
      workoutType == WorkoutType.segmentWithRecording ? [3, 7] : [8, 2];

  //TODO Placeholder functionality. Remove when implementing timer
  Timer countdownTimer;

  //camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isReady = false;
  bool _recording = false;
  bool isCameraFront = true;

  @override
  void initState() {
    _playCountdown();
    _setupCameras();
    this.workoutType = widget.workoutType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(
                flex: this.flexProportions(this.workoutType)[0],
                child: _timerSection(this.workoutType, this.workoutState)),
            Expanded(
                flex: this.flexProportions(this.workoutType)[1],
                child: _lowerSection(this.workoutType, this.workoutState))
          ]),
    );
  }

  /*
  View Sections
  */

  ///Countdown & movements information
  Widget _timerSection(WorkoutType workoutType, WorkoutState workoutState) {
    List<Widget> widgetsToShow = [
      Expanded(child: _countdownSection(workoutState)),
      Expanded(child: _tasksSection(tasks[0], tasks[1]))
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
  Widget _countdownSection(WorkoutState workoutState) {
    return Stack(fit: StackFit.loose, alignment: Alignment.center, children: [
      Padding(
        padding: const EdgeInsets.all(18.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                value:
                    this.timeLeft.inSeconds / this.movementDuration.inSeconds)),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(TimeConverter.durationToString(this.timeLeft),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          workoutState == WorkoutState.pause
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
  Widget _lowerSection(WorkoutType workoutType, WorkoutState workoutState) {
    return Container(
      color: Colors.black,
      child: workoutType == WorkoutType.segmentWithRecording
          ? _cameraSection()
          : _controlsSection(workoutState),
    );
  }

  ///Section with an Array of buttons to handle workout control from user
  Widget _controlsSection(WorkoutState workoutState) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: workoutState == WorkoutState.playing
            ? _onPlayingActions()
            : _onPausedActions(),
      ),
    );
  }

  ///Camera recording section. Shows camera Input and start/stop buttons.
  Widget _cameraSection() {
    //TODO Implement camera component.
    return Column(
      children: [
        Expanded(
          child: Container(
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
                        child: _feedbackButton(Icons.stop,
                            onPressed: () => this.setState(() {
                                  this.workoutType = WorkoutType.segment;
                                })))),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            right: 20.0, left: 80.0, top: 20.0, bottom: 20.0),
                        child: _flipCameraButton(Icons.flip_camera_android,
                            onPressed: () {
                          setState(() {
                            isCameraFront = !isCameraFront;
                          });
                          _setupCameras();
                        }))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ///Section with information about segment and workout movements.
  Widget _segmentInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MovementUtils.movementTitle(segmentName),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                '$rounds ${OlukoLocalizations.of(context).find('rounds')}',
                style: OlukoFonts.olukoBigFont()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MovementUtils.workout(tasks),
          ),
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

  List<Widget> _onPlayingActions() {
    return [
      OlukoPrimaryButton(
        color: Colors.white,
        title: OlukoLocalizations.of(context).find('pause').toUpperCase(),
        onPressed: () => this.setState(() {
          this.workoutState = WorkoutState.pause;
          _pauseCountdown();
        }),
        icon: Icon(Icons.pause),
      ),
      SizedBox(
        width: 25,
      ),
      OlukoPrimaryButton(
          color: Colors.white,
          onPressed: () => this.setState(() {
                this.workoutType = WorkoutType.segmentWithRecording;
              }),
          title: OlukoLocalizations.of(context).find('camera').toUpperCase(),
          icon: Icon(Icons.adjust))
    ];
  }

  List<Widget> _onPausedActions() {
    return [
      OlukoPrimaryButton(
        color: Colors.white,
        onPressed: () => this.setState(() {
          this.workoutState = WorkoutState.playing;
          _playCountdown();
        }),
        title:
            OlukoLocalizations.of(context).find('resumeWorkouts').toUpperCase(),
      ),
    ];
  }

  //TODO Implement this function with the Timer.
  void _playCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (timeLeft.inSeconds == 0) {
        _pauseCountdown();
        return;
      }
      this.setState(() {
        timeLeft = Duration(seconds: timeLeft.inSeconds - 1);
      });
    });
  }

  //TODO Implement this function with the Timer.
  void _pauseCountdown() {
    countdownTimer.cancel();
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

  Widget _flipCameraButton(IconData iconData, {Function() onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Icon(
        iconData,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  @override
  void dispose() {
    if (this.countdownTimer != null && this.countdownTimer.isActive) {
      this.countdownTimer.cancel();
    }
    super.dispose();
  }

  Future<void> _setupCameras() async {
    int cameraPos = isCameraFront ? 0 : 1;
    try {
      cameras = await availableCameras();
      cameraController =
          new CameraController(cameras[cameraPos], ResolutionPreset.medium);
      await cameraController.initialize();
    } on CameraException catch (_) {}
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }
}
