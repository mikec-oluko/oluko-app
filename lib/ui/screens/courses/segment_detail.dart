import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_audio_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_segment_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_stream_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/segment_detail_content_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
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
  List<Segment> _segments = [];
  List<Movement> _movements;
  PanelController panelController = PanelController();
  List<CoachRequest> _coachRequests;
  UserResponse _coach;
  final PanelController _challengePanelController = PanelController();
  CoachAssignment _coachAssignment;
  List<Challenge> _challenges;
  Class _class;
  int segmentIndexToUse;
  List<Audio> _currentAudios;
  AudioPlayer audioPlayer = AudioPlayer();

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
                  return const SizedBox.shrink();
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
              for (var segment in segmentState.segments) {
                for (var enrolledSegment in widget.courseEnrollment.classes[widget.classIndex].segments) {
                  if (segment.id == enrolledSegment.id &&
                      _segments.length < widget.courseEnrollment.classes[widget.classIndex].segments.length) {
                    _segments.add(segment);
                  }
                }
              }
              _movements = movementState.movements;
              _challenges = challengeSegmentState.challenges;
              totalSegments = _segments.length - 1;
              if (totalSegments < segmentIndexToUse) {
                segmentIndexToUse = 0;
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
                    BlocProvider.of<CoachRequestStreamBloc>(context).getStream(_user.id, _coachAssignment?.coachId);
                  }
                  return BlocBuilder<CoachUserBloc, CoachUserState>(builder: (context, coachUserState) {
                    return BlocBuilder<CoachRequestStreamBloc, CoachRequestStreamState>(builder: (context, coachRequestStreamState) {
                      if (coachUserState is CoachUserSuccess &&
                          (coachRequestStreamState is CoachRequestStreamSuccess ||
                              coachRequestStreamState is GetCoachRequestStreamUpdate)) {
                        List<CoachRequest> coachRequests;
                        if (coachRequestStreamState is CoachRequestStreamSuccess) {
                          coachRequests = coachRequestStreamState.values;
                        }
                        if (coachRequestStreamState is GetCoachRequestStreamUpdate) {
                          coachRequests = coachRequestStreamState.values;
                        }
                        _coach = coachUserState.coach;
                        _coachRequests = coachRequests
                            .where((coachRequest) =>
                                (_coach == null &&
                                    coachRequest.courseEnrollmentId == widget.courseEnrollment.id &&
                                    coachRequest.classId == widget.courseEnrollment.classes[widget.classIndex].id) ||
                                (coachRequest.coachId == _coach.id &&
                                    coachRequest.courseEnrollmentId == widget.courseEnrollment.id &&
                                    coachRequest.classId == widget.courseEnrollment.classes[widget.classIndex].id))
                            .toList();
                        return form();
                      } else {
                        return OlukoCircularProgressIndicator();
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
        color: OlukoNeumorphismColors.appBackgroundColor,
        minHeight: 0.0,
        maxHeight: MediaQuery.of(context).size.height / 1.5,
        collapsed: const SizedBox(),
        controller: _challengePanelController,
        panel: BlocBuilder<SegmentDetailContentBloc, SegmentDetailContentState>(builder: (context, state) {
          return manageSegmentDetailContentState(state);
        }),
      ),
    );
  }

  Widget manageSegmentDetailContentState(SegmentDetailContentState state) {
    Widget _contentForPanel = const SizedBox();
    if (state is SegmentDetailContentDefault) {
      if (_challengePanelController.isPanelOpen) {
        _challengePanelController.close();
      }
      _contentForPanel = const SizedBox();
    } else if (state is SegmentDetailContentAudioOpen) {
      _currentAudios = state.audios;
      if (_currentAudios != null && _currentAudios.length > 0) {
        _challengePanelController.open();
        _contentForPanel = ModalAudio(
            comesFromSegmentDetail: true,
            challenge: state.challenge,
            audioPlayer: audioPlayer,
            audios: _currentAudios,
            panelController: _challengePanelController,
            onAudioPressed: (int index, Challenge challenge) => _onAudioDeleted(index, challenge));
      }
    } else if (state is SegmentDetailContentPeopleOpen) {
      _challengePanelController.open();
      _contentForPanel = ModalPeopleEnrolled(
          userProgressStreamBloc: BlocProvider.of<UserProgressStreamBloc>(context),
          userProgressListBloc: BlocProvider.of<UserProgressListBloc>(context),
          userId: _user.id,
          favorites: state.favorites,
          users: state.users);
    } else if (state is SegmentDetailContentClockOpen) {
      _challengePanelController.open();
      _contentForPanel = ModalPersonalRecord(segmentId: state.segmentId, userId: _user.id);
    } else if (state is SegmentDetailContentLoading) {
      _contentForPanel = UploadingModalLoader(UploadFrom.segmentDetail);
    }
    return _contentForPanel;
  }

  _onAudioDeleted(int audioIndex, Challenge challenge) {
    _currentAudios[audioIndex].deleted = true;
    List<Audio> audiosUpdated = _currentAudios.toList();
    _currentAudios.removeAt(audioIndex);
    BlocProvider.of<ChallengeAudioBloc>(context).markAudioAsDeleted(challenge, audiosUpdated, _currentAudios);
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
          height: ScreenUtils.height(context),
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
      segmentWidgets.add(challengeCarouselSection(i));
    }
    return segmentWidgets;
  }

  Widget challengeCarouselSection(int i) {
    return Container(
        height: ScreenUtils.height(context),
        child: SlidingUpPanel(
            controller: panelController,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            minHeight: 90,
            maxHeight: 185,
            collapsed: CollapsedMovementVideosSection(action: getAction()),
            panel: movementsPanel(i),
            body: getSegmentImageSection(i)));
  }

  Widget getSegmentImageSection(int i) {
    Challenge challenge = getSegmentChallenge(_segments[i].id);
    return SegmentImageSection(
      onPressed: () => onPressedAction(),
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
      fromChallenge: widget.fromChallenge,
    );
  }

  void onPressedAction() {
    if (widget.fromChallenge) {
      return;
    } else {
      Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.insideClass]));
      final arguments = {'courseEnrollment': widget.courseEnrollment, 'classIndex': widget.classIndex, 'courseIndex': widget.courseIndex};
      if (Navigator.canPop(context)) {
        Navigator.pushReplacementNamed(
          context,
          routeLabels[RouteEnum.insideClass],
          arguments: arguments,
        );
      } else {
        Navigator.pushNamed(
          context,
          routeLabels[RouteEnum.insideClass],
          arguments: arguments,
        );
      }
    }
    ;
  }

  Widget movementsPanel(int i) {
    if (_segments.length - 1 >= segmentIndexToUse) {
      return MovementVideosSection(
          action: OlukoNeumorphism.isNeumorphismDesign ? SizedBox.shrink() : downButton(),
          segment: _segments[i],
          movements: _movements,
          onPressedMovement: (BuildContext context, Movement movement) =>
              Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement}));
    }
    return const SizedBox();
  }

  Widget _viewBody() {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
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

  _audioAction(List<Audio> audios, Challenge challenge) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openAudioPanel(audios, challenge);
  }

  _peopleAction(List<UserSubmodel> users, List<UserSubmodel> favorites) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openPeoplePanel(users, favorites);
  }

  _clockAction(String segmentId) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openClockPanel(segmentId);
  }
}
