import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/countdown_overlay.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/segment_image_section.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/screens/courses/segment_recording.dart';
import 'package:oluko_app/ui/screens/courses/segment_camera_preview.dart.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/timer_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SegmentDetail extends StatefulWidget {
  SegmentDetail(
      {this.courseEnrollment, this.segmentIndex, this.classIndex, Key key})
      : super(key: key);

  final CourseEnrollment courseEnrollment;
  final int segmentIndex;
  final int classIndex;

  @override
  _SegmentDetailState createState() => _SegmentDetailState();
}

class _SegmentDetailState extends State<SegmentDetail> {
  final toolbarHeight = kToolbarHeight * 2;
  num currentSegmentStep;
  num totalSegmentStep;
  User _user;
  List<Segment> _segments;

  @override
  void initState() {
    currentSegmentStep = widget.segmentIndex + 1;
    totalSegmentStep =
        widget.courseEnrollment.classes[widget.classIndex].segments.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.firebaseUser;
        return BlocBuilder<SegmentBloc, SegmentState>(
            builder: (context, segmentState) {
          if (segmentState is GetSegmentsSuccess) {
            _segments = segmentState.segments;
            return form();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        child: _viewBody(),
      ),
    );
  }

  Widget _viewBody() {
    return Container(
      child: ListView(children: [
        SegmentImageSection(
            segment: _segments[widget.segmentIndex],
            currentSegmentStep: currentSegmentStep,
            totalSegmentStep: totalSegmentStep),
        _menuOptions()
      ]),
    );
  }

  _menuOptions() {
    return Column(
      children: [
        //Submit button
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 25.0),
          child: Row(children: [
            OlukoPrimaryButton(
                title: OlukoLocalizations.of(context).find('startWorkouts'),
                color: OlukoColors.primary,
                onPressed: () {
                  BottomDialogUtils.showBottomDialog(
                      context: context, content: dialogContainer());
                })
          ]),
        )
      ],
    );
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

  Widget dialogContainer() {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/courses/dialog_background.png"),
          fit: BoxFit.cover,
        )),
        child: Stack(children: [
          Column(children: [
            SizedBox(height: 30),
            Stack(alignment: Alignment.center, children: [
              StoriesItem(
                  maxRadius: 65,
                  imageUrl:
                      "https://firebasestorage.googleapis.com/v0/b/oluko-development.appspot.com/o/coach_mike.png?alt=media&token=ead25dbe-f6e5-4857-a2ed-9d77f146ee72"),
              Image.asset('assets/courses/photo_ellipse.png', scale: 4)
            ]),
            SizedBox(height: 15),
            Text("Coach Mike",
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoSuperBigFont(
                    custoFontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                    "Coach Mike has requested you to record the segment",
                    textAlign: TextAlign.center,
                    style: OlukoFonts.olukoBigFont())),
            SizedBox(height: 35),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OlukoOutlinedButton(
                      title: OlukoLocalizations.of(context).find('ignore'),
                      onPressed: () {
                        //TODO: Make rounds dynamic
                        TimerUtils.startCountdown(
                            WorkoutType.segment,
                            context,
                            getArguments(),
                            _segments[widget.segmentIndex].initialTimer,
                            8,
                            2);
                      },
                    ),
                    SizedBox(width: 20),
                    OlukoPrimaryButton(
                      title: 'Ok',
                      onPressed: () {
                        Navigator.pushNamed(context,
                            routeLabels[RouteEnum.segmentCameraPreview],
                            arguments: {
                              'segmentIndex': widget.segmentIndex,
                              'classIndex': widget.classIndex,
                              'courseEnrollment': widget.courseEnrollment,
                              'segments': _segments,
                            });
                      },
                    )
                  ],
                )),
          ]),
          Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context)))
        ]));
  }

  Object getArguments() {
    return {
      'segmentIndex': widget.segmentIndex,
      'classIndex': widget.classIndex,
      'courseEnrollment': widget.courseEnrollment,
      'workoutType': WorkoutType.segment,
      'segments': _segments,
    };
  }
}
