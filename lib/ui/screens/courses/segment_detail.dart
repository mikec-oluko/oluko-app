import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_segment_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/segment_detail_content_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/modal_audio.dart';
import 'package:oluko_app/ui/components/modal_people_enrolled.dart';
import 'package:oluko_app/ui/components/modal_personal_record.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/segment_image_section.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SegmentDetail extends StatefulWidget {
  SegmentDetail({this.courseIndex, this.courseEnrollment, this.segmentIndex, this.classIndex, this.fromChallenge = false, Key key})
      : super(key: key);

  final CourseEnrollment courseEnrollment;
  final int segmentIndex;
  final int classIndex;
  final int courseIndex;
  final bool fromChallenge;

  @override
  _SegmentDetailState createState() => _SegmentDetailState();
}

class _SegmentDetailState extends State<SegmentDetail> {
  final toolbarHeight = kToolbarHeight * 2;
  int currentSegmentStep;
  int totalSegmentStep;
  int totalSegments;
  bool hasCourseStructureDiscrepancies = false;
  UserResponse _user;
  List<Segment> _segments;
  List<Movement> _movements;
  PanelController panelController = PanelController();
  List<CoachRequest> _coachRequests;
  UserResponse _coach;
  final PanelController _challengePanelController = PanelController();
  CoachAssignment _coachAssignment;
  List<Challenge> _challenges;
  Class _class;
  int segmentIndexToUse;

  @override
  void initState() {
    _coachRequests = [];
    segmentIndexToUse = widget.segmentIndex;
    currentSegmentStep = widget.segmentIndex + 1;
    totalSegmentStep = widget.courseEnrollment.classes[widget.classIndex].segments.length;
    super.initState();
  }

  Challenge getSegmentChallenge(String segmentId) {
    if (_challenges != null) {
      for (var i = 0; i < _challenges.length; i++) {
        if (_challenges[i].segmentId == segmentId) {
          return _challenges[i];
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.user;
        BlocProvider.of<CoachAssignmentBloc>(context).getCoachAssignmentStatus(_user.id);
        widget.fromChallenge ? BlocProvider.of<ClassBloc>(context).get(widget.courseEnrollment.classes[widget.classIndex].id) : null;
        BlocProvider.of<ChallengeSegmentBloc>(context)
            .getByClass(widget.courseEnrollment.id, widget.courseEnrollment.classes[widget.classIndex].id);
        return widget.fromChallenge
            ? BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
                if (classState is GetByIdSuccess) {
                  _class = classState.classObj;
                  BlocProvider.of<SegmentBloc>(context).getAll(_class);
                  BlocProvider.of<MovementBloc>(context).getAll();
                  return segmentDetailView();
                } else {
                  return const SizedBox();
                }
              })
            : segmentDetailView();
      } else {
        return OlukoCircularProgressIndicator();
      }
    });
  }

  BlocBuilder<SegmentBloc, SegmentState> segmentDetailView() {
    return BlocBuilder<SegmentBloc, SegmentState>(builder: (context, segmentState) {
      return BlocBuilder<ChallengeSegmentBloc, ChallengeSegmentState>(
        builder: (context, challengeSegmentState) {
          return BlocBuilder<MovementBloc, MovementState>(builder: (context, movementState) {
            if (segmentState is GetSegmentsSuccess && movementState is GetAllSuccess && challengeSegmentState is ChallengesSuccess) {
              _segments = segmentState.segments;
              _movements = movementState.movements;
              _challenges = challengeSegmentState.challenges;
              totalSegments = _segments.length - 1;
              if (totalSegments < segmentIndexToUse) {
                segmentIndexToUse = 0; //TODO: restarts if segment wanted doesn't exists
                currentSegmentStep = 1;
                totalSegmentStep = totalSegments + 1;
              } else if (totalSegments < totalSegmentStep - 1) {
                totalSegmentStep = totalSegments + 1;
              }
              return BlocBuilder<CoachAssignmentBloc, CoachAssignmentState>(
                builder: (context, state) {
                  if (state is CoachAssignmentResponse) {
                    _coachAssignment = state.coachAssignmentResponse;
                    BlocProvider.of<CoachUserBloc>(context).get(_coachAssignment?.coachId);
                    BlocProvider.of<CoachRequestBloc>(context).getClassCoachRequest(
                        userId: _user.id,
                        coachId: _coachAssignment?.coachId,
                        courseEnrollmentId: widget.courseEnrollment.id,
                        classId: widget.courseEnrollment.classes[widget.classIndex].id);
                  }
                  return BlocBuilder<CoachUserBloc, CoachUserState>(builder: (context, coachUserState) {
                    return BlocBuilder<CoachRequestBloc, CoachRequestState>(builder: (context, coachRequestState) {
                      if (coachUserState is CoachUserSuccess && coachRequestState is ClassCoachRequestsSuccess) {
                        _coach = coachUserState.coach;
                        _coachRequests = coachRequestState.coachRequests;
                        return form();
                      } else {
                        return SizedBox();
                      }
                    });
                  });
                },
              );
            } else {
              return OlukoCircularProgressIndicator();
            }
          });
        },
      );
    });
  }

  Widget form() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        child: Stack(
          children: [
            _viewBody(),
            slidingUpPanelComponent(context),
          ],
        ),
      ),
    );
  }

  BlocListener<SegmentDetailContentBloc, SegmentDetailContentState> slidingUpPanelComponent(BuildContext context) {
    return BlocListener<SegmentDetailContentBloc, SegmentDetailContentState>(
      listener: (context, state) {},
      child: SlidingUpPanel(
        onPanelClosed: () {
          BlocProvider.of<SegmentDetailContentBloc>(context).emitDefaultState();
        },
        backdropEnabled: true,
        isDraggable: false,
        header: const SizedBox(),
        padding: EdgeInsets.zero,
        color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : Colors.black,
        minHeight: 0.0,
        maxHeight: MediaQuery.of(context).size.height / 1.5, //TODO: dynamic size, for content
        collapsed: const SizedBox(),
        controller: _challengePanelController,
        panel: BlocBuilder<SegmentDetailContentBloc, SegmentDetailContentState>(builder: (context, state) {
          Widget _contentForPanel = const SizedBox();
          if (state is SegmentDetailContentDefault) {
            if (_challengePanelController.isPanelOpen) {
              _challengePanelController.close();
            }
            _contentForPanel = const SizedBox();
          }
          if (state is SegmentDetailContentAudioOpen) {
            _challengePanelController.open();
            _contentForPanel = ModalAudio(audios: state.audios);
          }
          if (state is SegmentDetailContentPeopleOpen) {
            _challengePanelController.open();
            _contentForPanel = ModalPeopleEnrolled(userId: _user.id, favorites: state.favorites, users: state.users);
          }
          if (state is SegmentDetailContentClockOpen) {
            _challengePanelController.open();
            _contentForPanel = ModalPersonalRecord(
                segmentId: widget.courseEnrollment.classes[widget.classIndex].segments[segmentIndexToUse].id, userId: _user.id);
          }
          if (state is SegmentDetailContentLoading) {
            _contentForPanel = UploadingModalLoader(UploadFrom.segmentDetail);
          }
          return _contentForPanel;
        }),
      ),
    );
  }

  Widget downButton() {
    return GestureDetector(
        onTap: () => panelController.close(),
        child: Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 5, right: 25),
            child: RotatedBox(
                quarterTurns: 2,
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/courses/white_arrow_up.png',
                    scale: 4,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 15),
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
            padding: const EdgeInsets.only(top: 10, bottom: 15, right: 25),
            child: Stack(alignment: Alignment.center, children: [
              Image.asset(
                'assets/courses/white_arrow_up.png',
                scale: 4,
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Image.asset(
                    'assets/courses/grey_arrow_up.png',
                    scale: 4,
                  ))
            ])));
  }

  Widget getCarouselSlider() {
    return CarouselSlider(
      items: getSegmentList(),
      options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          autoPlay: false,
          enlargeCenterPage: false,
          disableCenter: true,
          enableInfiniteScroll: false,
          initialPage: segmentIndexToUse,
          viewportFraction: 1),
    );
  }

  //TODO: CONTENT PARA IR AL SEGMENT/CHALLENGE
  List<Widget> getSegmentList() {
    List<Widget> segmentWidgets = [];
    for (var i = 0; i < _segments.length; i++) {
      Challenge challenge = getSegmentChallenge(_segments[i].id);
      segmentWidgets.add(SlidingUpPanel(
          controller: panelController,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          minHeight: 90,
          maxHeight: 185,
          collapsed: CollapsedMovementVideosSection(action: getAction()),
          panel: () {
            if (_segments.length - 1 >= segmentIndexToUse) {
              return MovementVideosSection(
                  action: OlukoNeumorphism.isNeumorphismDesign ? SizedBox.shrink() : downButton(),
                  segment: _segments[i],
                  movements: _movements,
                  onPressedMovement: (BuildContext context, Movement movement) =>
                      Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement}));
            }
            return const SizedBox();
          }(),
          body: SegmentImageSection(
              onPressed: () => widget.fromChallenge
                  ? (() {})
                  : Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass], arguments: {
                      'courseEnrollment': widget.courseEnrollment,
                      'classIndex': widget.classIndex,
                      'courseIndex': widget.courseIndex
                    }),
              segment: _segments[i],
              challenge: challenge,
              currentSegmentStep: i + 1,
              totalSegmentStep: totalSegmentStep,
              userId: _user.id,
              audioAction: _audioAction,
              peopleAction: _peopleAction,
              clockAction: _clockAction,
              courseEnrollment: widget.courseEnrollment,
              courseIndex: widget.courseIndex,
              segments: _segments,
              classIndex: widget.classIndex,
              coachRequests: _coachRequests,
              coach: _coach,
              fromChallenge: widget.fromChallenge)));
    }
    return segmentWidgets;
  }

  Widget _viewBody() {
    return Container(
      color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : Colors.black,
      child: Column(
        children: [
          () {
            if (_segments.length - 1 >= segmentIndexToUse) {
              return getCarouselSlider();
            }
            return const SizedBox();
          }(),
        ],
      ),
    );
  }

  List<Widget> _confirmDialogContent() {
    return [
      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
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

  _audioAction(List<Audio> audios) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openAudioPanel(audios);
  }

  _peopleAction(List<UserSubmodel> users, List<UserSubmodel> favorites) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openPeoplePanel(users, favorites);
  }

  _clockAction() {
    BlocProvider.of<SegmentDetailContentBloc>(context).openClockPanel();
  }
}
