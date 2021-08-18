import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/IntervalProgressBarLib/interval_progress_bar.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SegmentTimers extends StatefulWidget {
  SegmentTimers({Key key}) : super(key: key);

  @override
  _SegmentTimersState createState() => _SegmentTimersState();
}

class _SegmentTimersState extends State<SegmentTimers> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return form();
  }

  Widget form() {
    return Scaffold(
      appBar: OlukoAppBar(
        showDivider: false,
        title: ' ',
        actions: [topCameraIcon(), audioIcon()],
      ),
      backgroundColor: Colors.black,
      body: SlidingUpPanel(
          //controller: panelController,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          minHeight: 90,
          collapsed: CollapsedMovementVideosSection(),
          panel: MovementVideosSection(),
          body: timersSection()),
    );
  }

  Widget timersSection() {
    return Container(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        child: Column(children: [
          Padding(
              padding: EdgeInsets.only(top: 30),
              child: Stack(
                  alignment: Alignment.center,
                  children: [
                        buildCircle(),
                      ] +
                      timeTimer())),
          SizedBox(height: 50),
          _tasksSection("5 Sec Chin-Ups", "5 Sec rest"),
        ]));
  }

  Widget _tasksSection(String currentTask, String nextTask) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentTask,
            style: TextStyle(
                fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ShaderMask(
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
          ),
        ],
      ),
    );
  }

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

  List<Widget> timeTimer() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 98.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                value: 0.3,
                color: OlukoColors.coral,
                backgroundColor: OlukoColors.grayColor)),
      ),
      Text(TimeConverter.durationToString(Duration(seconds: 8)),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white))
    ];
  }

  List<Widget> preTimer(String type, int round) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 98.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                value: 0.4,
                color: OlukoColors.coral,
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
    ];
  }

  List<Widget> pausedTimer() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 98.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                value: 0,
                color: OlukoColors.skyblue,
                backgroundColor: OlukoColors.grayColor)),
      ),
      Column(children: [
        Text("PAUSED",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: OlukoColors.skyblue)),
        SizedBox(height: 12),
        Text(TimeConverter.durationToString(Duration(seconds: 30)),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
      ])
    ];
  }

  List<Widget> restTimer() {
    double ellipseScale = 4.5;
    return [
      Image.asset(
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
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 98.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                value: 1,
                color: OlukoColors.skyblue,
                backgroundColor: OlukoColors.grayColor)),
      ),
      Column(children: [
        Text("REST",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: OlukoColors.skyblue)),
        SizedBox(height: 12),
        Text(TimeConverter.durationToString(Duration(seconds: 30)),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
      ])
    ];
  }

  List<Widget> repsTimer() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 98.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                value: 0,
                color: OlukoColors.skyblue,
                backgroundColor: OlukoColors.grayColor)),
      ),
      Column(children: [
        Text("Tap here",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: OlukoColors.primary)),
        SizedBox(height: 8),
        Text("when completed",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: OlukoColors.primary))
      ])
    ];
  }
}
