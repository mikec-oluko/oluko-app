import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar_with_image.dart';
import 'package:oluko_app/ui/components/countdown_overlay.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/screens/segment_recording.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class SegmentDetail extends StatefulWidget {
  SegmentDetail({Key key}) : super(key: key);

  @override
  _SegmentDetailState createState() => _SegmentDetailState();
}

class _SegmentDetailState extends State<SegmentDetail> {
  final toolbarHeight = kToolbarHeight * 2;
  bool startRecordingAndWorkoutTogether = false;

  //TODO Make Dynamic
  String segmentTitle = "Intense Airsquat";
  String backgroundImageUrl =
      'https://c0.wallpaperflare.com/preview/26/779/700/fitness-men-sports-gym.jpg';
  String segmentDescription =
      "Each round is considered to be completed once all the workouts are finished.";
  List<String> segmentMovements = ['30 sec airsquats', '30 sec rest'];
  //Used in "segment 1/4"
  num currentSegmentStep = 1;
  num totalSegmentStep = 4;
  // ---------

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoImageBar(actions: []),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.94), BlendMode.darken),
                fit: BoxFit.cover,
                image: NetworkImage(backgroundImageUrl))),
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context) - toolbarHeight,
        child: _viewBody(),
      ),
    );
  }

  Widget _viewBody() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MovementUtils.movementTitle(segmentTitle),
                      SizedBox(height: 25),
                      MovementUtils.description(segmentDescription),
                      SizedBox(height: 25),
                      MovementUtils.workout(segmentMovements),
                    ],
                  ),
                )
              ]),
              _menuOptions()
            ]),
      ),
    );
  }

  _menuOptions() {
    return Column(
      children: [
        //Coach recommended section
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: OlukoColors.listGrayColor),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(OlukoLocalizations.of(context)
                            .find('coachRecommended')),
                      ))
                ]),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.videocam_outlined,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        OlukoLocalizations.of(context)
                            .find('startVideoAndWorkoutTogether'),
                        style: OlukoFonts.olukoMediumFont(),
                      ),
                    ),
                    Checkbox(
                      value: startRecordingAndWorkoutTogether,
                      onChanged: (bool value) {
                        this.setState(() {
                          startRecordingAndWorkoutTogether = value;
                        });
                      },
                      fillColor: MaterialStateProperty.all(Colors.white),
                      checkColor: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        //Segment section
        Container(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${OlukoLocalizations.of(context).find('segment')} $currentSegmentStep/$totalSegmentStep',
                      style: OlukoFonts.olukoMediumFont(),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 15,
                      ),
                      Icon(
                        Icons.adjust,
                        color: Colors.white,
                        size: 15,
                      ),
                      Icon(
                        Icons.adjust,
                        color: Colors.white,
                        size: 15,
                      ),
                      Icon(
                        Icons.adjust,
                        color: Colors.white,
                        size: 15,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        //Submit button
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(children: [
            OlukoPrimaryButton(
                title: OlukoLocalizations.of(context).find('startWorkouts'),
                color: Colors.white,
                onPressed: () {
                  startRecordingAndWorkoutTogether
                      ? _startCountdown(WorkoutType.segmentWithRecording)
                      : MovementUtils.movementDialog(
                              context, _confirmDialogContent())
                          .then((value) => value != null
                              ? _startCountdown(value == true
                                  ? WorkoutType.segmentWithRecording
                                  : WorkoutType.segment)
                              : null);
                })
          ]),
        )
      ],
    );
  }

  _startCountdown(WorkoutType workoutType) {
    return Navigator.of(context)
        .push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => CountdownOverlay(
                  seconds: 5,
                  title: workoutType == WorkoutType.segmentWithRecording
                      ? OlukoLocalizations.of(context)
                          .find("segmentAndRecordingStartsIn")
                      : OlukoLocalizations.of(context).find("segmentStartsIn"),
                )))
        .then((value) => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SegmentRecording(workoutType: workoutType))));
  }

  List<Widget> _confirmDialogContent() {
    return [
      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            OlukoLocalizations.of(context).find('coachRecommendsRecording'),
            textAlign: TextAlign.center,
            style: OlukoFonts.olukoBigFont()),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          children: [
            OlukoPrimaryButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              color: Colors.white,
              title:
                  OlukoLocalizations.of(context).find('recordAndStartSegment'),
            ),
          ],
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: Text(
          OlukoLocalizations.of(context).find('continueWithoutRecording'),
          style: OlukoFonts.olukoMediumFont(),
        ),
      )
    ];
  }
}
