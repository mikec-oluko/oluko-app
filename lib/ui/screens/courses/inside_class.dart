import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/ui/components/challenge_section.dart';
import 'package:oluko_app/ui/components/class_movements_section.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/courses/audio_dialog_content.dart';
import 'package:oluko_app/ui/screens/courses/class_detail_section.dart';
import 'package:oluko_app/ui/screens/courses/course_info_section.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'audio_panel.dart';

enum PanelEnum { audios, classDetail }

class InsideClass extends StatefulWidget {
  InsideClass({this.courseEnrollment, this.classIndex, Key key})
      : super(key: key);

  final CourseEnrollment courseEnrollment;
  final int classIndex;

  @override
  _InsideClassesState createState() => _InsideClassesState();
}

class FirebaseUser {}

class _InsideClassesState extends State<InsideClass> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  Class _class;
  List<Movement> _movements;
  PanelController panelController = new PanelController();
  List<Movement> _classMovements;

  Widget panelContent;
  PanelEnum panelState;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        BlocProvider.of<ClassBloc>(context)
          ..get(widget.courseEnrollment.classes[widget.classIndex].id);
        BlocProvider.of<MovementBloc>(context)..getAll();
        return BlocBuilder<ClassBloc, ClassState>(
            builder: (context, classState) {
          if (classState is GetByIdSuccess) {
            _class = classState.classObj;
            BlocProvider.of<SegmentBloc>(context)..getAll(_class);
            BlocProvider.of<CoachUserBloc>(context)
              ..getByAudios(
                  widget.courseEnrollment.classes[widget.classIndex].audios);
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
    return Form(
        key: _formKey,
        child: Scaffold(body: BlocBuilder<MovementBloc, MovementState>(
            builder: (context, movementState) {
          if (movementState is GetAllSuccess) {
            _movements = movementState.movements;
            return BlocBuilder<CoachUserBloc, CoachUserState>(
                builder: (context, coachState) {
              if (coachState is CoachesByAudiosSuccess) {
                return SlidingUpPanel(
                    controller: panelController,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    minHeight: 5,
                    collapsed: Container(
                      color: Colors.black,
                    ),
                    panel: /*audioSection(coachState.coaches)*/ classDetailSection(),
                    body: Container(
                      color: Colors.black,
                      child: classInfoSection(
                          widget.courseEnrollment.classes[widget.classIndex]
                              .audios[0],
                          coachState.coaches[0]),
                    ));
              } else {
                return SizedBox();
              }
            });
          } else {
            return SizedBox();
          }
        })));
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5,
            minHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }

  Widget _startButton() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        OlukoPrimaryButton(
          title: OlukoLocalizations.get(context, 'start'),
          onPressed: () {
            int segmentIndex =
                CourseEnrollmentService.getFirstUncompletedSegmentIndex(
                    widget.courseEnrollment.classes[widget.classIndex]);
            if (segmentIndex == -1) {
              segmentIndex = 0;
            }
            Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail],
                arguments: {
                  'segmentIndex': segmentIndex,
                  'classIndex': widget.classIndex,
                  'courseEnrollment': widget.courseEnrollment,
                });
          },
        ),
      ],
    );
  }

  Widget buildChallengeSection() {
    List<SegmentSubmodel> challenges = getChallenges();
    if (challenges.length > 0) {
      return ChallengeSection(
        addTitle: true,
        challenges: challenges,
      );
    } else {
      return SizedBox();
    }
  }

  List<SegmentSubmodel> getChallenges() {
    List<SegmentSubmodel> challenges = [];
    _class.segments.forEach((SegmentSubmodel segment) {
      if (segment.challengeImage != null) {
        challenges.add(segment);
      }
    });
    return challenges;
  }

  Widget classMovementSection() {
    _classMovements = ClassService.getClassMovements(_class, _movements);
    return ClassMovementSection(
      panelController: panelController,
      movements: _classMovements,
      classObj: _class,
      onPressedMovement: (BuildContext context, Movement movement) =>
          Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro],
              arguments: {'movement': movement}),
    );
  }

  Widget classDetailSection() {
    return BlocBuilder<SegmentBloc, SegmentState>(
        builder: (context, segmentState) {
      if (segmentState is GetSegmentsSuccess) {
        return ClassDetailSection(
            classObj: _class,
            movements: _movements,
            segments: segmentState.segments);
      } else {
        return SizedBox();
      }
    });
  }

  Widget audioSection(List<UserResponse> coaches) {
    return AudioPanel(
      coaches: coaches,
      audios: widget.courseEnrollment.classes[widget.classIndex].audios,
    );
  }

  Widget classInfoSection(Audio audio, UserResponse coach) {
    return ListView(children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: OverlayVideoPreview(
              video: _class.video,
              showBackButton: true,
              bottomWidgets: [
                CourseInfoSection(
                    onAudioPressed: () {
                      /*BottomDialogUtils.showBottomDialog(
                          context: context,
                          content:
                              AudioDialogContent(coach: coach, audio: audio));*/
                    },
                    peopleQty: 50,
                    audioMessageQty: widget.courseEnrollment
                        .classes[widget.classIndex].audios.length,
                    image: widget.courseEnrollment.course.image)
              ])),
      Padding(
          padding: EdgeInsets.only(right: 15, left: 15, top: 25),
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _startButton(),
                    Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          _class.name,
                          style: OlukoFonts.olukoTitleFont(
                              custoFontWeight: FontWeight.bold),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, right: 10),
                      child: Text(
                        TimeConverter.toClassProgress(widget.classIndex,
                            widget.courseEnrollment.classes.length, context),
                        style: OlukoFonts.olukoBigFont(
                            custoFontWeight: FontWeight.normal,
                            customColor: OlukoColors.primary),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: CourseProgressBar(
                            value: CourseEnrollmentService.getClassProgress(
                                widget.courseEnrollment, widget.classIndex))),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        _class.description,
                        style: OlukoFonts.olukoBigFont(
                            custoFontWeight: FontWeight.normal,
                            customColor: OlukoColors.grayColor),
                      ),
                    ),
                    buildChallengeSection(),
                    classMovementSection(),
                  ]))),
    ]);
  }
}
