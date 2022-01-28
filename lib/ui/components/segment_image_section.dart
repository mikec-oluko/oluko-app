import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/challenge/challenge_audio_bloc.dart';
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
import 'package:oluko_app/services/audio_service.dart';
import 'package:oluko_app/ui/components/audio_section.dart';
import 'package:oluko_app/ui/components/coach_request_content.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/people_section.dart';
import 'package:oluko_app/ui/components/segment_step_section.dart';
import 'package:oluko_app/ui/components/vertical_divider.dart' as verticalDivider;
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
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
  final Function(List<Audio> audios, Challenge challenge) audioAction;
  final Function(List<UserSubmodel> users, List<UserSubmodel> favorites) peopleAction;
  final Function() clockAction;
  final CourseEnrollment courseEnrollment;
  final int courseIndex;
  final int classIndex;
  final List<Segment> segments;
  final List<CoachRequest> coachRequests;
  final UserResponse coach;
  final Challenge challenge;
  final bool fromChallenge;

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
      this.fromChallenge,
      Key key})
      : super(key: key);

  @override
  _SegmentImageSectionState createState() => _SegmentImageSectionState();
}

class _SegmentImageSectionState extends State<SegmentImageSection> {
  CoachRequest _coachRequest;
  bool _canStartSegment = true;
  List<Audio> _challengeAudios;
  int _audioQty;

  @override
  void initState() {
    _challengeAudios = widget.challenge == null ? null : AudioService.getNotDeletedAudios(widget.challenge.audios);
    _coachRequest = getSegmentCoachRequest(widget.segment.id);
    _canStartSegment = canStartSegment();
    BlocProvider.of<DoneChallengeUsersBloc>(context).get(widget.segment.id, widget.userId);
    _audioQty = _challengeAudios != null ? _challengeAudios.length : 0;
    super.initState();
  }

  bool canStartSegment() {
    if (widget.currentSegmentStep < 2) return true;
    return widget.courseEnrollment.classes[widget.classIndex].segments[widget.currentSegmentStep - 2].completedAt != null;
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.popUntil(context, ModalRoute.withName('/inside-class'));
          return Future(() => false);
        },
        child: imageWithButtons());
  }

  Widget imageWithButtons() {
    return Stack(children: [
      ListView(padding: OlukoNeumorphism.isNeumorphismDesign ? EdgeInsets.zero : null, children: [
        Stack(children: [
          imageSection(),
          if (widget.segment.isChallenge) challengeButtons(),
          //TODO: SEGMENT INFO
          Padding(
            padding: EdgeInsets.symmetric(horizontal: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0),
            child: segmentContent(),
          ),
        ]),
        const SizedBox(
          height: 130,
        ),
        //TODO: START WORKOUT
      ]),
      Positioned(bottom: 100, child: Align(child: SizedBox(width: ScreenUtils.width(context), child: startWorkoutsButton()))),
      //TODO: Navigation buttons
      topButtons(),
    ]);
  }

  Widget segmentContent() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Padding(
            padding: EdgeInsets.only(top: ScreenUtils.height(context) * 0.5),
            child: segmentInformation(),
          )
        : Padding(padding: EdgeInsets.only(top: ScreenUtils.height(context) * 0.25, right: 15, left: 15), child: segmentInformation());
  }

  Column segmentInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: OlukoNeumorphism.isNeumorphismDesign ? MediaQuery.of(context).size.width - 40 : null,
          child: Text(
            widget.segment.isChallenge ? (OlukoLocalizations.get(context, 'challengeTitle') + widget.segment.name) : widget.segment.name,
            style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
            overflow: OlukoNeumorphism.isNeumorphismDesign ? TextOverflow.clip : null,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: OlukoNeumorphism.isNeumorphismDesign ? MediaQuery.of(context).size.width - 40 : null,
          child: Text(
            widget.segment.description,
            style: OlukoFonts.olukoBigFont(
                custoFontWeight: OlukoNeumorphism.isNeumorphismDesign ? FontWeight.w300 : FontWeight.w400,
                customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.white),
            overflow: OlukoNeumorphism.isNeumorphismDesign ? TextOverflow.clip : null,
          ),
        ),
        SegmentStepSection(currentSegmentStep: widget.currentSegmentStep, totalSegmentStep: widget.totalSegmentStep),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: SegmentUtils.getSegmentSummary(
                    widget.segment, context, OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.white))),
      ],
    );
  }

  // TODO: CHECK IF IS DISABLE/ENABLE BUTTON
  Widget startWorkoutsButton() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? (widget.segment.isChallenge && _canStartSegment) || !widget.segment.isChallenge
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: OlukoNeumorphicPrimaryButton(
                    useBorder: true,
                    thinPadding: true,
                    isExpanded: false,
                    title: OlukoNeumorphism.isNeumorphismDesign
                        ? OlukoLocalizations.get(context, 'start')
                        : OlukoLocalizations.get(context, 'startWorkouts'),
                    onPressed: () {
                      if (_coachRequest != null) {
                        //TODO: CHECK CHALLENGE
                        BottomDialogUtils.showBottomDialog(
                            context: context,
                            content: CoachRequestContent(
                                name: widget.coach.firstName,
                                image: widget.coach.avatar,
                                onNotRecordingAction: navigateToSegmentWithoutRecording,
                                onRecordingAction: navigateToSegmentWithRecording));
                      } else {
                        navigateToSegmentWithoutRecording();
                      }
                    }),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OlukoNeumorphicPrimaryButton(
                    useBorder: true,
                    thinPadding: true,
                    isExpanded: false,
                    title: OlukoLocalizations.get(context, 'locked'),
                    onPressed: () {}),
              )
        : Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              OlukoPrimaryButton(
                  title: OlukoNeumorphism.isNeumorphismDesign
                      ? OlukoLocalizations.get(context, 'start')
                      : OlukoLocalizations.get(context, 'startWorkouts'),
                  color: OlukoColors.primary,
                  onPressed: () {
                    if (_coachRequest != null) {
                      BottomDialogUtils.showBottomDialog(
                          context: context,
                          content: CoachRequestContent(
                              name: widget.coach.firstName,
                              image: widget.coach.avatar,
                              onNotRecordingAction: navigateToSegmentWithoutRecording,
                              onRecordingAction: navigateToSegmentWithRecording));
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
      'fromChallenge': widget.fromChallenge
    };
  }

  Widget topButtons() {
    return Padding(
        padding:
            const EdgeInsets.only(top: OlukoNeumorphism.isNeumorphismDesign ? 50 : 15, left: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0),
        child: Row(
          children: [
            if (widget.showBackButton)
              !OlukoNeumorphism.isNeumorphismDesign
                  ? IconButton(
                      icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        if (widget.onPressed != null) {
                          widget.onPressed();
                        }
                      })
                  : OlukoNeumorphicCircleButton(
                      customIcon: const Icon(Icons.arrow_back, color: OlukoColors.grayColor),
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
    if (widget.fromChallenge) {
      return const SizedBox();
    } else {
      return Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Stack(
              alignment: Alignment.center,
              children: getCameraCircles() +
                  [
                    Image.asset('assets/courses/outlined_camera.png',
                        scale: 3, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary),
                    const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(Icons.circle_outlined,
                            size: 16, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary))
                  ]));
    }
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
    return OlukoNeumorphism.isNeumorphismDesign
        ? ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [OlukoNeumorphismColors.olukoNeumorphicBackgroundDark, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: imageContainer(),
          )
        : imageContainer();
  }

  Stack imageContainer() {
    return Stack(alignment: Alignment.center, children: [
      if (OlukoNeumorphism.isNeumorphismDesign)
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.3,
          child: imageAspecRatio(),
        )
      else
        imageAspecRatio(),
      Image.asset(
        'assets/courses/degraded.png',
        scale: 4,
      ),
    ]);
  }

  AspectRatio imageAspecRatio() {
    return AspectRatio(
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
        }());
  }

  Widget challengeButtons() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Padding(
            padding: EdgeInsets.only(left: 20, top: ScreenUtils.height(context) * 0.35),
            child: challengeButtonsContent(),
          )
        : Padding(
            padding: EdgeInsets.only(left: 20, top: ScreenUtils.height(context) * 0.13),
            child: challengeButtonsContent(),
          );
  }

  Column challengeButtonsContent() {
    const verticalDividerComponent = verticalDivider.VerticalDivider(
      width: 30,
      height: OlukoNeumorphism.isNeumorphismDesign ? 80 : 60,
    );
    return Column(children: [
      Row(children: [
        getAudioButton(),
        verticalDividerComponent,
        BlocBuilder<DoneChallengeUsersBloc, DoneChallengeUsersState>(builder: (context, doneChallengeUsersState) {
          if (doneChallengeUsersState is DoneChallengeUsersSuccess) {
            final int favorites = doneChallengeUsersState.favoriteUsers != null ? doneChallengeUsersState.favoriteUsers.length : 0;
            final int normalUsers = doneChallengeUsersState.users != null ? doneChallengeUsersState.users.length : 0;
            final int qty = favorites + normalUsers;
            return Buttons(
              widget: widget,
              qty: qty,
              state: doneChallengeUsersState,
            );
          } else {
            return Buttons(widget: widget);
          }
        }),
        if (OlukoNeumorphism.isNeumorphismDesign) verticalDividerComponent else const SizedBox(),
        GestureDetector(onTap: widget.clockAction, child: clockSection()),
      ])
    ]);
  }

  Widget getAudioButton() {
    return BlocBuilder<ChallengeAudioBloc, ChallengeAudioState>(builder: (context, state) {
      if (state is DeleteChallengeAudioSuccess) {
        _audioQty = state.audios.length;
      }
      return GestureDetector(
          onTap: () => widget.audioAction(_challengeAudios, widget.challenge), child: AudioSection(audioMessageQty: _audioQty));
    });
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

  _onStartPressed() {
    //CoachRequest coachRequest = getSegmentCoachRequest(widget.segment.id);
    if (_coachRequest != null) {
      BottomDialogUtils.showBottomDialog(
          context: context,
          content: CoachRequestContent(
              name: widget.coach.firstName,
              image: widget.coach.avatar,
              onNotRecordingAction: navigateToSegmentWithoutRecording,
              onRecordingAction: navigateToSegmentWithRecording));
    } else {
      navigateToSegmentWithoutRecording();
    }
  }
}

class Buttons extends StatelessWidget {
  const Buttons({
    Key key,
    @required this.widget,
    this.state,
    this.qty,
  }) : super(key: key);

  final SegmentImageSection widget;
  final DoneChallengeUsersSuccess state;
  final int qty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (state != null)
          GestureDetector(
            onTap: () => widget.peopleAction(state.users, state.favoriteUsers),
            child: PeopleSection(peopleQty: qty, isChallenge: widget.segment.isChallenge),
          )
        else
          PeopleSection(peopleQty: 0, isChallenge: widget.segment.isChallenge),
        const verticalDivider.VerticalDivider(
          width: 30,
          height: OlukoNeumorphism.isNeumorphismDesign ? 80 : 60,
        ),
        if (OlukoNeumorphism.isNeumorphismDesign)
          Column(
            children: [
              Text(
                OlukoLocalizations.get(context, 'includedIn'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
              ),
              Text(
                state != null && state.occurrencesInClasses != null ? state.occurrencesInClasses.toString() : '0',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: OlukoColors.primary),
              ),
              const SizedBox(height: 5),
              Text(
                OlukoLocalizations.get(context, 'classes').toLowerCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
              ),
            ],
          )
        else
          const SizedBox(),
      ],
    );
  }
}
