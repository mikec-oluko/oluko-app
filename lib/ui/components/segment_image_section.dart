import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/done_challenge_users_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/audio_section.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/people_section.dart';
import 'package:oluko_app/ui/components/segment_step_section.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/vertical_divider.dart' as verticalDivider;
import 'package:oluko_app/ui/screens/courses/audio_panel.dart';
import 'package:oluko_app/ui/screens/courses/segment_clocks.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/timer_utils.dart';

class SegmentImageSection extends StatefulWidget {
  final Function() onPressed;
  final Segment segment;
  final bool showBackButton;
  final int currentSegmentStep;
  final int totalSegmentStep;
  final String userId;
  final Function(List<Audio> audios) audioAction;
  final Function(List<UserSubmodel> users, List<UserSubmodel> favorites) peopleAction;
  final Function() clockAction;
  final CourseEnrollment courseEnrollment;
  final int courseIndex;
  final int classIndex;
  final List<Segment> segments;
  final List<CoachRequest> coachRequests;
  final UserResponse coach;
  final Challenge challenge;

  SegmentImageSection(
      {this.onPressed = null,
      this.segment,
      this.showBackButton = true,
      this.currentSegmentStep,
      this.totalSegmentStep,
      this.challenge,
      this.userId,
      this.audioAction,
      this.clockAction,
      this.peopleAction,
      this.courseEnrollment,
      this.courseIndex,
      this.segments,
      this.classIndex,
      this.coachRequests,
      this.coach,
      Key key})
      : super(key: key);

  @override
  _SegmentImageSectionState createState() => _SegmentImageSectionState();
}

class _SegmentImageSectionState extends State<SegmentImageSection> {
  CoachRequest _coachRequest;

  @override
  void initState() {
    _coachRequest = getSegmentCoachRequest(widget.segment.id);
    BlocProvider.of<DoneChallengeUsersBloc>(context).get(widget.segment.id, widget.userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return imageWithButtons();
  }

  Widget imageWithButtons() {
    return Stack(children: [
      Container(
          height: ScreenUtils.height(context) - 100,
          child: ListView(children: [
            Stack(children: [
              imageSection(),
              if (widget.segment.isChallenge) challengeButtons(),
              segmentContent(),
            ]),
            startWorkoutsButton()
          ])),
      topButtons(),
    ]);
  }

  Widget segmentContent() {
    return Padding(
        padding: const EdgeInsets.only(top: 270, right: 15, left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.segment.isChallenge ? (OlukoLocalizations.get(context, 'challengeTitle') + widget.segment.name) : widget.segment.name,
              style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.segment.description,
              style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400),
            ),
            SegmentStepSection(currentSegmentStep: widget.currentSegmentStep, totalSegmentStep: widget.totalSegmentStep),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: SegmentUtils.getSegmentSummary(widget.segment, context, OlukoColors.white))),
          ],
        ));
  }

  Widget startWorkoutsButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 25.0),
      child: Row(children: [
        OlukoPrimaryButton(
            title: OlukoLocalizations.get(context, 'startWorkouts'),
            color: OlukoColors.primary,
            onPressed: () {
              //CoachRequest coachRequest = getSegmentCoachRequest(widget.segment.id);
              if (_coachRequest != null) {
                BottomDialogUtils.showBottomDialog(context: context, content: dialogContainer(widget.coach.firstName, widget.coach.avatar));
              } else {
                navigateToSegmentWithoutRecording();
              }
            })
      ]),
    );
  }

  CoachRequest getSegmentCoachRequest(String segmentId) {
    for (var i = 0; i < widget.coachRequests.length; i++) {
      if (widget.coachRequests[i].segmentId == segmentId) {
        return widget.coachRequests[i];
      }
    }
    return null;
  }

  Widget dialogContainer(String name, String image) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/courses/dialog_background.png'),
          fit: BoxFit.cover,
        )),
        child: Stack(children: [
          Column(children: [
            const SizedBox(height: 30),
            Stack(alignment: Alignment.center, children: [
              StoriesItem(maxRadius: 65, imageUrl: image /*, bloc: StoryListBloc()*/),
              Image.asset('assets/courses/photo_ellipse.png', scale: 4)
            ]),
            const SizedBox(height: 15),
            Text('${OlukoLocalizations.get(context, 'coach')} $name',
                textAlign: TextAlign.center, style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text('${OlukoLocalizations.get(context, 'coach')} $name ${OlukoLocalizations.get(context, 'coachRequest')}',
                    textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont())),
            const SizedBox(height: 35),
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
                    const SizedBox(width: 20),
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
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))
        ]));
  }

  navigateToSegmentWithRecording() {
    Navigator.pushNamed(context, routeLabels[RouteEnum.segmentCameraPreview], arguments: {
      'segmentIndex': widget.currentSegmentStep - 1,
      'classIndex': widget.classIndex,
      'courseEnrollment': widget.courseEnrollment,
      'courseIndex': widget.courseIndex,
      'segments': widget.segments,
    });
  }

  navigateToSegmentWithoutRecording() {
    TimerUtils.startCountdown(WorkoutType.segment, context, getArguments(), widget.segment.initialTimer, widget.segment.rounds, 0);
  }

  Object getArguments() {
    return {
      'segmentIndex': widget.currentSegmentStep - 1,
      'classIndex': widget.classIndex,
      'courseEnrollment': widget.courseEnrollment,
      'courseIndex': widget.courseIndex,
      'workoutType': WorkoutType.segment,
      'segments': widget.segments,
    };
  }

  Widget topButtons() {
    return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Row(
          children: [
            if (widget.showBackButton)
              IconButton(
                  icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onPressed != null) {
                      widget.onPressed();
                    }
                  })
            else
              const SizedBox(),
            const Expanded(child: SizedBox()),
            getCameraIcon()
          ],
        ));
  }

  Widget getCameraIcon() {
    return Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Stack(
            alignment: Alignment.center,
            children: getCameraCircles() +
                [
                  Image.asset(
                    'assets/courses/outlined_camera.png',
                    scale: 3,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.circle_outlined, size: 16, color: OlukoColors.primary))
                ]));
  }

  List<Widget> getCameraCircles() {
    if (_coachRequest != null) {
      return [
        Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Image.asset(
              'assets/courses/green_ellipse_1.png',
              scale: 3,
            )),
        Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Image.asset(
              'assets/courses/green_ellipse_2.png',
              scale: 3,
            )),
        Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Image.asset(
              'assets/courses/green_ellipse_3.png',
              scale: 3,
            ))
      ];
    } else {
      return [];
    }
  }

  Widget imageSection() {
    return Stack(alignment: Alignment.center, children: [
      AspectRatio(
          aspectRatio: 3 / 4,
          child: () {
            if (widget.segment.image != null) {
              return Image.network(
                widget.segment.image,
                fit: BoxFit.cover,
              );
            } else {
              return nil;
            }
          }()),
      Image.asset(
        'assets/courses/degraded.png',
        scale: 4,
      ),
    ]);
  }

  Widget challengeButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 190),
      child: Column(children: [
        Row(children: [
          GestureDetector(
              onTap: () => widget.audioAction(widget.challenge.audios),
              child: AudioSection(audioMessageQty: widget.challenge.audios != null ? widget.challenge.audios.length : 0)),
          const verticalDivider.VerticalDivider(
            width: 30,
            height: 60,
          ),
          BlocBuilder<DoneChallengeUsersBloc, DoneChallengeUsersState>(builder: (context, doneChallengeUsersState) {
            if (doneChallengeUsersState is DoneChallengeUsersSuccess) {
              final int favorites = doneChallengeUsersState.favoriteUsers != null ? doneChallengeUsersState.favoriteUsers.length : 0;
              final int normalUsers = doneChallengeUsersState.users != null ? doneChallengeUsersState.users.length : 0;
              final int qty = favorites + normalUsers;
              return GestureDetector(
                  onTap: () => widget.peopleAction(doneChallengeUsersState.users, doneChallengeUsersState.favoriteUsers),
                  child: PeopleSection(peopleQty: qty, isChallenge: widget.segment.isChallenge));
            } else {
              return PeopleSection(peopleQty: 0, isChallenge: widget.segment.isChallenge);
            }
          }),
          const verticalDivider.VerticalDivider(
            width: 30,
            height: 60,
          ),
          GestureDetector(onTap: widget.clockAction, child: clockSection()),
        ])
      ]),
    );
  }

  Widget clockSection() {
    return Container(
      width: 60,
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Image.asset(
              'assets/courses/clock.png',
              height: 24,
              width: 27,
            )),
        const SizedBox(height: 5),
        Text(
          OlukoLocalizations.get(context, 'personalRecord'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
        )
      ]),
    );
  }
}
