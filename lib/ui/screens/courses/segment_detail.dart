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
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/segment_detail_content_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/modal_audio.dart';
import 'package:oluko_app/ui/components/modal_people_enrolled.dart';
import 'package:oluko_app/ui/components/modal_personal_record.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/segment_image_section.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SegmentDetail extends StatefulWidget {
  SegmentDetail({this.classSegments, this.courseIndex, this.courseEnrollment, this.segmentIndex, this.classIndex, this.fromChallenge = false, Key key})
      : super(key: key);

  final CourseEnrollment courseEnrollment;
  final int segmentIndex;
  final int classIndex;
  final int courseIndex;
  final bool fromChallenge;
  final List<Segment> classSegments;

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
  PanelController panelController = PanelController();
  List<CoachRequest> _coachRequests;
  UserResponse _coach;
  final PanelController _challengePanelController = PanelController();
  CoachAssignment _coachAssignment;
  List<Challenge> _challenges = [];
  int segmentIndexToUse;
  List<Audio> _currentAudios;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    _coachRequests = [];
    segmentIndexToUse = widget.segmentIndex;
    currentSegmentStep = widget.segmentIndex + 1;
    // TODO: SEGMENT FROM COURSE ENROLLMENT WITH ENROLLMENT SEGMENT
    totalSegmentStep = widget.courseEnrollment.classes[widget.classIndex].segments.length;
    setSegments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.user;
        BlocProvider.of<CoachAssignmentBloc>(context).getCoachAssignmentStatus(_user.id);
        widget.fromChallenge ? BlocProvider.of<ClassBloc>(context).get(widget.courseEnrollment.classes[widget.classIndex].id) : null;
        BlocProvider.of<ChallengeSegmentBloc>(context).getByClass(widget.courseEnrollment.id, widget.courseEnrollment.classes[widget.classIndex].id);
        return _segmentDetailView();
      } else {
        return OlukoCircularProgressIndicator();
      }
    });
  }

  Widget _segmentDetailView() {
    return BlocListener<CoachAssignmentBloc, CoachAssignmentState>(
        listener: (context, state) {
          if (state is CoachAssignmentResponse) {
            _coachAssignment = state.coachAssignmentResponse;
            BlocProvider.of<CoachUserBloc>(context).get(_coachAssignment?.coachId);
            BlocProvider.of<CoachRequestStreamBloc>(context).getStream(_user.id, _coachAssignment?.coachId);
          }
        },
        child: form());
  }

  Widget form() {
    return Scaffold(
      backgroundColor: OlukoColors.black,
      body: SizedBox(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        child: Stack(
          children: [
            _body(),
            slidingUpPanelComponent(),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return widget.classSegments == null
        ? BlocBuilder<SegmentBloc, SegmentState>(builder: (context, segmentState) {
            if (segmentState is GetSegmentsSuccess) {
              _segments = segmentState.segments;
              setTotalSegments();
              return _viewBody();
            } else {
              return OlukoCircularProgressIndicator();
            }
          })
        : _viewBody();
  }

  Widget _viewBody() {
    return BlocBuilder<ChallengeSegmentBloc, ChallengeSegmentState>(builder: (context, challengeSegmentState) {
      if (challengeSegmentState is ChallengesSuccess) {
        _challenges = challengeSegmentState.challenges;
      }
      return Container(
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: Column(
          children: [(_segments.length - 1 >= segmentIndexToUse) ? getCarouselSlider() : const SizedBox()],
        ),
      );
    });
  }

  Widget slidingUpPanelComponent() {
    return SlidingUpPanel(
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
      panel: manageSegmentDetailContentState(),
    );
  }

  Widget manageSegmentDetailContentState() {
    Widget _contentForPanel = const SizedBox();
    return BlocBuilder<SegmentDetailContentBloc, SegmentDetailContentState>(builder: (context, state) {
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
    });
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
    return BlocBuilder<CoachUserBloc, CoachUserState>(
        buildWhen: (CoachUserState previous, CoachUserState current) => previous is CoachUserLoading,
        builder: (context, coachUserState) {
          return BlocBuilder<CoachRequestStreamBloc, CoachRequestStreamState>(builder: (context, coachRequestStreamState) {
            if (coachUserState is CoachUserSuccess &&
                (coachRequestStreamState is CoachRequestStreamSuccess || coachRequestStreamState is GetCoachRequestStreamUpdate)) {
              coachLogic(coachUserState, coachRequestStreamState);
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
            } else {
              return OlukoCircularProgressIndicator();
            }
          });
        });
  }

  void coachLogic(CoachUserSuccess coachUserState, CoachRequestStreamState coachRequestStreamState) {
    List<CoachRequest> coachRequests;
    if (coachRequestStreamState is CoachRequestStreamSuccess) {
      coachRequests = coachRequestStreamState.values;
    } else if (coachRequestStreamState is GetCoachRequestStreamUpdate) {
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
          onPressedMovement: (BuildContext context, MovementSubmodel movementSubmodel) =>
              Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': movementSubmodel}));
    }
    return const SizedBox();
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

  void setSegments() {
    if (widget.classSegments != null) {
      // TODO: SEGMENT WITH MOVEMENT REFERENCE FROM ACTUAL SEGMENT
      _segments = widget.classSegments;
      setTotalSegments();
    } else {
      BlocProvider.of<SegmentBloc>(context).getSegmentsInClass(widget.courseEnrollment.classes[widget.classIndex]);
    }
  }

  void setTotalSegments() {
    totalSegments = _segments.length - 1;
    if (totalSegments < segmentIndexToUse) {
      segmentIndexToUse = 0;
      currentSegmentStep = 1;
      totalSegmentStep = totalSegments + 1;
    } else if (totalSegments < totalSegmentStep - 1) {
      totalSegmentStep = totalSegments + 1;
    }
  }

  void _audioAction(List<Audio> audios, Challenge challenge) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openAudioPanel(audios, challenge);
  }

  void _peopleAction(List<UserSubmodel> users, List<UserSubmodel> favorites) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openPeoplePanel(users, favorites);
  }

  void _clockAction(String segmentId) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openClockPanel(segmentId);
  }
}
