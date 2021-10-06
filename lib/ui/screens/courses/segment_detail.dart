import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/segment_image_section.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/segment_clocks.dart';
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
  int currentSegmentStep;
  int totalSegmentStep;
  User _user;
  List<Segment> _segments;
  List<Movement> _movements;
  PanelController panelController = new PanelController();
  CoachRequest _coachRequest;
  UserResponse _coach;

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
          return BlocBuilder<MovementBloc, MovementState>(
              builder: (context, movementState) {
            if (segmentState is GetSegmentsSuccess &&
                movementState is GetAllSuccess) {
              _segments = segmentState.segments;
              _movements = movementState.movements;
              return BlocListener<CoachUserBloc, CoachUserState>(
                  listener: (context, coachUserState) {
                    if (coachUserState is CoachUserSuccess) {
                      _coach = coachUserState.coach;
                    }
                  },
                  child: BlocListener<CoachRequestBloc, CoachRequestState>(
                      listener: (context, coachRequestState) {
                        if (coachRequestState is GetCoachRequestSuccess) {
                          _coachRequest = coachRequestState.coachRequest;
                          BlocProvider.of<CoachUserBloc>(context)
                            ..get(_coachRequest.coachId);
                        }
                      },
                      child: form()));
            } else {
              return OlukoCircularProgressIndicator();
            }
          });
        });
      } else {
        return OlukoCircularProgressIndicator();
      }
    });
  }

  Widget form() {
    BlocProvider.of<CoachRequestBloc>(context)
      ..getBySegment(
          _user.uid,
          widget.courseEnrollment.classes[widget.classIndex]
              .segments[widget.segmentIndex].id,
          widget.courseEnrollment.id);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        child: SlidingUpPanel(
            controller: panelController,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            minHeight: 90,
            maxHeight: 185,
            collapsed: CollapsedMovementVideosSection(action: getAction()),
            panel: MovementVideosSection(
                action: downButton(),
                segment: _segments[widget.segmentIndex],
                movements: _movements,
                onPressedMovement: (BuildContext context, Movement movement) =>
                    Navigator.pushNamed(
                        context, routeLabels[RouteEnum.movementIntro],
                        arguments: {'movement': movement})),
            body: _viewBody()),
      ),
    );
  }

  Widget downButton() {
    return GestureDetector(
        onTap: () => panelController.close(),
        child: Padding(
            padding: EdgeInsets.only(top: 15, bottom: 5, right: 25),
            child: RotatedBox(
                quarterTurns: 2,
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/courses/white_arrow_up.png',
                    scale: 4,
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Image.asset(
                        'assets/courses/grey_arrow_up.png',
                        scale: 4,
                      ))
                ]))));
  }

  Widget getAction() {
    return GestureDetector(
        onTap: () => panelController.open(),
        child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 15, right: 25),
            child: Stack(alignment: Alignment.center, children: [
              Image.asset(
                'assets/courses/white_arrow_up.png',
                scale: 4,
              ),
              Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Image.asset(
                    'assets/courses/grey_arrow_up.png',
                    scale: 4,
                  ))
            ])));
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

  Widget _menuOptions() {
    return Column(
      children: [
        //Submit button
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 25.0),
          child: Row(children: [
            OlukoPrimaryButton(
                title: OlukoLocalizations.get(context, 'startWorkouts'),
                color: OlukoColors.primary,
                onPressed: () {
                  if (_coachRequest != null && _coach != null) {
                    BottomDialogUtils.showBottomDialog(
                        context: context,
                        content:
                            dialogContainer(_coach.firstName, _coach.avatar));
                  } else {
                    navigateToSegmentWithoutRecording();
                  }
                })
          ]),
        ),
        SizedBox(height: 85)
      ],
    );
  }

  List<Widget> _confirmDialogContent() {
    return [
      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(OlukoLocalizations.get(context, 'coachRecommendsRecording'),
            textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
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
              title: OlukoLocalizations.get(context, 'recordAndStartSegment'),
            ),
          ],
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: Text(
          OlukoLocalizations.get(context, 'continueWithoutRecording'),
          style: OlukoFonts.olukoMediumFont(),
        ),
      )
    ];
  }

  Widget dialogContainer(String name, String image) {
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
              StoriesItem(maxRadius: 65, imageUrl: image),
              Image.asset('assets/courses/photo_ellipse.png', scale: 4)
            ]),
            SizedBox(height: 15),
            Text(OlukoLocalizations.get(context, 'coach') + " " + name,
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoSuperBigFont(
                    custoFontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                    OlukoLocalizations.get(context, 'coach') +
                        " " +
                        name +
                        " " +
                        OlukoLocalizations.get(context, 'coachRequest'),
                    textAlign: TextAlign.center,
                    style: OlukoFonts.olukoBigFont())),
            SizedBox(height: 35),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OlukoOutlinedButton(
                      title: OlukoLocalizations.get(context, 'ignore'),
                      onPressed: () {
                        navigateToSegmentWithoutRecording();
                      },
                    ),
                    SizedBox(width: 20),
                    OlukoPrimaryButton(
                      title: 'Ok',
                      onPressed: () {
                        navigateToSegmentWithRecording();
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

  navigateToSegmentWithRecording() {
    Navigator.pushNamed(context, routeLabels[RouteEnum.segmentCameraPreview],
        arguments: {
          'segmentIndex': widget.segmentIndex,
          'classIndex': widget.classIndex,
          'courseEnrollment': widget.courseEnrollment,
          'segments': _segments,
        });
  }

  navigateToSegmentWithoutRecording() {
    TimerUtils.startCountdown(
        WorkoutType.segment,
        context,
        getArguments(),
        _segments[widget.segmentIndex].initialTimer,
        _segments[widget.segmentIndex].rounds,
        0);
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
