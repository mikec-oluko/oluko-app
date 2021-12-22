import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/segment_detail_content_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
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
  SegmentDetail({this.courseIndex, this.courseEnrollment, this.segmentIndex, this.classIndex, Key key}) : super(key: key);

  final CourseEnrollment courseEnrollment;
  int segmentIndex;
  final int classIndex;
  final int courseIndex;

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

  @override
  void initState() {
    _coachRequests = [];
    currentSegmentStep = widget.segmentIndex + 1;
    totalSegmentStep = widget.courseEnrollment.classes[widget.classIndex].segments.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.user;
        BlocProvider.of<CoachAssignmentBloc>(context).getCoachAssignmentStatus(_user.id);
        return BlocBuilder<SegmentBloc, SegmentState>(builder: (context, segmentState) {
          return BlocBuilder<MovementBloc, MovementState>(builder: (context, movementState) {
            if (segmentState is GetSegmentsSuccess && movementState is GetAllSuccess) {
              _segments = segmentState.segments;
              _movements = movementState.movements;
              totalSegments = _segments.length - 1;
              if (totalSegments < widget.segmentIndex) {
                widget.segmentIndex = 0; //TODO: restarts if segment wanted doesn't exists
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
        });
      } else {
        return OlukoCircularProgressIndicator();
      }
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
            SlidingUpPanel(
                controller: panelController,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                minHeight: 90,
                maxHeight: 185,
                collapsed: CollapsedMovementVideosSection(action: getAction()),
                panel: () {
                  if (_segments.length - 1 >= widget.segmentIndex) {
                    return MovementVideosSection(
                        action: downButton(),
                        segment: _segments[widget.segmentIndex],
                        movements: _movements,
                        onPressedMovement: (BuildContext context, Movement movement) =>
                            Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement}));
                  }
                  return const SizedBox();
                }(),
                body: _viewBody()),
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
        color: OlukoColors.black,
        minHeight: 0.0,
        maxHeight: 450, //TODO
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
            _contentForPanel = Container(child: Text('audio'));
          }
          if (state is SegmentDetailContentPeopleOpen) {
            _challengePanelController.open();
            _contentForPanel = ModalPeopleEnrolled(userId: _user.id, favorites: state.favorites, users: state.users);
          }
          if (state is SegmentDetailContentClockOpen) {
            _challengePanelController.open();
            _contentForPanel = ModalPersonalRecord(
                segmentId: widget.courseEnrollment.classes[widget.classIndex].segments[widget.segmentIndex].id, userId: _user.id);
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
          height: 760,
          autoPlay: false,
          enlargeCenterPage: false,
          disableCenter: true,
          enableInfiniteScroll: false,
          initialPage: widget.segmentIndex,
          viewportFraction: 1),
    );
  }

  List<Widget> getSegmentList() {
    List<Widget> segmentWidgets = [];
    for (var i = 0; i < _segments.length; i++) {
      segmentWidgets.add(SegmentImageSection(
          onPressed: () => Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass],
              arguments: {'courseEnrollment': widget.courseEnrollment, 'classIndex': widget.classIndex, 'courseIndex': widget.courseIndex}),
          segment: _segments[i],
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
          coach: _coach));
    }
    return segmentWidgets;
  }

  Widget _viewBody() {
    return Column(
      children: [
        () {
          if (_segments.length - 1 >= widget.segmentIndex) {
            return getCarouselSlider();
          }
          return const SizedBox();
        }(),
      ],
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

  _audioAction() {
    BlocProvider.of<SegmentDetailContentBloc>(context).openAudioPanel();
  }

  _peopleAction(List<UserSubmodel> users, List<UserSubmodel> favorites) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openPeoplePanel(users, favorites);
  }

  _clockAction() {
    BlocProvider.of<SegmentDetailContentBloc>(context).openClockPanel();
  }
}
