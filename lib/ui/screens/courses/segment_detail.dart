import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/ui/components/oluko_image_bar.dart';
import 'package:oluko_app/ui/components/countdown_overlay.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/segment_step_section.dart';
import 'package:oluko_app/ui/screens/courses/segment_recording.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'movement_intro.dart';

class SegmentDetail extends StatefulWidget {
  SegmentDetail(
      {this.segments,
      this.courseEnrollment,
      this.segmentIndex,
      this.classIndex,
      this.user,
      Key key})
      : super(key: key);

  List<Segment> segments;
  CourseEnrollment courseEnrollment;
  int segmentIndex;
  int classIndex;
  User user;

  @override
  _SegmentDetailState createState() => _SegmentDetailState();
}

class _SegmentDetailState extends State<SegmentDetail> {
  final toolbarHeight = kToolbarHeight * 2;
  bool startRecordingAndWorkoutTogether = false;

  num currentSegmentStep;
  num totalSegmentStep;
  MovementBloc _movementBloc;

  @override
  void initState() {
    currentSegmentStep = widget.segmentIndex + 1;
    totalSegmentStep =
        widget.courseEnrollment.classes[widget.classIndex].segments.length;
    _movementBloc = MovementBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<MovementBloc>(
            create: (context) => _movementBloc..getBySegment(widget.segments[widget.segmentIndex]),
          )
        ],
        child:
            BlocBuilder<MovementBloc, MovementState>(builder: (context, state) {
          if (state is GetMovementsSuccess) {
            return form(state.movements);
          } else {
            return SizedBox();
          }
        }));
  }

  Widget form(List<Movement> movements) {
    return Scaffold(
      appBar: OlukoImageBar(
        actions: [],
        movements: movements,
        onPressedMovement: (BuildContext context, Movement movement) =>
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MovementIntro(movement: movement))),
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.85), BlendMode.darken),
                fit: BoxFit.cover,
                image: NetworkImage(widget.segments[widget.segmentIndex].image))),
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
        child: ListView(children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MovementUtils.movementTitle(widget.segments[widget.segmentIndex].name),
                        SizedBox(height: 25),
                        MovementUtils.description(
                            widget.segments[widget.segmentIndex].description, context),
                        SizedBox(height: 25),
                        MovementUtils.workout(widget.segments[widget.segmentIndex], context),
                      ],
                    ),
                  )
                ]),
                _menuOptions()
              ])
        ]),
      ),
    );
  }

  _menuOptions() {
    return Column(
      children: [
        //Coach recommended section
        Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Container(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
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
            )),
        //Segment section
        SegmentStepSection(
            currentSegmentStep: currentSegmentStep,
            totalSegmentStep: totalSegmentStep),
        //Submit button
        Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 25.0),
          child: Row(children: [
            OlukoPrimaryButton(
                title: OlukoLocalizations.of(context)
                    .find('startWorkouts')
                    .toUpperCase(),
                color: Colors.white,
                onPressed: () {
                  startRecordingAndWorkoutTogether
                      ? _startCountdown(WorkoutType.segmentWithRecording)
                      : DialogUtils.getDialog(
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
                builder: (context) => SegmentRecording(
                    user: widget.user,
                    workoutType: workoutType,
                    courseEnrollment: widget.courseEnrollment,
                    segmentIndex: widget.segmentIndex,
                    classIndex: widget.classIndex,
                    segments: widget.segments))));
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
