import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_bloc.dart';
import 'package:oluko_app/blocs/inside_class_content_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/audio_service.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/ui/components/challenge_section.dart';
import 'package:oluko_app/ui/components/class_movements_section.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/modal_audio.dart';
import 'package:oluko_app/ui/components/modal_people_enrolled.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/courses/audio_dialog_content.dart';
import 'package:oluko_app/ui/screens/courses/class_detail_section.dart';
import 'package:oluko_app/ui/screens/courses/course_info_section.dart';
import 'package:oluko_app/ui/screens/courses/explore_subscribed_users.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'audio_panel.dart';

enum PanelEnum { audios, classDetail }

class InsideClass extends StatefulWidget {
  InsideClass({this.courseEnrollment, this.classIndex, this.courseIndex, Key key, this.classImage}) : super(key: key);

  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int courseIndex;
  final String classImage;

  @override
  _InsideClassesState createState() => _InsideClassesState();
}

class FirebaseUser {}

class _InsideClassesState extends State<InsideClass> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  Class _class;
  List<Movement> _movements;
  PanelController panelController = PanelController();
  final PanelController _buttonController = PanelController();
  List<Movement> _classMovements;
  List<UserResponse> _coaches;
  List<Audio> _audios = [];

  Widget panelContent;
  PanelEnum panelState;

  @override
  void initState() {
    _audios = widget.courseEnrollment.classes[widget.classIndex].audios;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        BlocProvider.of<ClassBloc>(context).get(widget.courseEnrollment.classes[widget.classIndex].id);
        BlocProvider.of<MovementBloc>(context).getAll();
        return BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
          if (classState is GetByIdSuccess) {
            _class = classState.classObj;
            BlocProvider.of<SegmentBloc>(context).getAll(_class);
            BlocProvider.of<CoachAudioBloc>(context).getByAudios(_audios);
            BlocProvider.of<SubscribedCourseUsersBloc>(context).get(widget.courseEnrollment.course.id, authState.user.id);
            return form();
          } else {
            return const SizedBox();
          }
        });
      } else {
        return const SizedBox();
      }
    });
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(body: BlocBuilder<MovementBloc, MovementState>(builder: (context, movementState) {
          if (movementState is GetAllSuccess) {
            _movements = movementState.movements;
            return BlocBuilder<CoachAudioBloc, CoachAudioState>(builder: (context, coachState) {
              if (coachState is CoachesByAudiosSuccess) {
                _coaches = coachState.coaches;
                return Stack(
                  children: [
                    SlidingUpPanel(
                        controller: panelController,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        minHeight: 5,
                        collapsed: Container(
                          color: Colors.black,
                        ),
                        panel: classDetailSection(),
                        body: Container(
                          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColorFadeBottom : Colors.black,
                          child: classInfoSection(coachState.coaches),
                        )),
                    slidingUpPanelComponent(context)
                  ],
                );
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
        whenInitialized: (ChewieController chewieController) => this.setState(() {
              _controller = chewieController;
            })));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).orientation == Orientation.portrait
                ? ScreenUtils.height(context) / 4
                : ScreenUtils.height(context) / 1.5,
            minHeight: MediaQuery.of(context).orientation == Orientation.portrait
                ? ScreenUtils.height(context) / 4
                : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }

  Widget _startButton() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 50,
                child: OlukoNeumorphicPrimaryButton(
                  isExpanded: false,
                  thinPadding: true,
                  title: OlukoLocalizations.get(context, 'start'),
                  onPressed: () {
                    int segmentIndex =
                        CourseEnrollmentService.getFirstUncompletedSegmentIndex(widget.courseEnrollment.classes[widget.classIndex]);
                    if (segmentIndex == -1) {
                      segmentIndex = 0;
                    }
                    Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
                      'segmentIndex': segmentIndex,
                      'classIndex': widget.classIndex,
                      'courseEnrollment': widget.courseEnrollment,
                      'courseIndex': widget.courseIndex
                    });
                  },
                ),
              )
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              OlukoPrimaryButton(
                title: OlukoLocalizations.get(context, 'start'),
                onPressed: () {
                  int segmentIndex =
                      CourseEnrollmentService.getFirstUncompletedSegmentIndex(widget.courseEnrollment.classes[widget.classIndex]);
                  if (segmentIndex == -1) {
                    segmentIndex = 0;
                  }
                  Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
                    'segmentIndex': segmentIndex,
                    'classIndex': widget.classIndex,
                    'courseEnrollment': widget.courseEnrollment,
                    'courseIndex': widget.courseIndex
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
          Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement}),
    );
  }

  Widget classDetailSection() {
    return BlocBuilder<SegmentBloc, SegmentState>(builder: (context, segmentState) {
      if (segmentState is GetSegmentsSuccess) {
        return ClassDetailSection(classObj: _class, movements: _movements, segments: segmentState.segments);
      } else {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/courses/gray_background.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: segmentState is LoadingSegment ? OlukoCircularProgressIndicator() : const SizedBox());
      }
    });
  }

  Widget classInfoSection(List<UserResponse> coaches) {
    return ListView(children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: OverlayVideoPreview(
            video: _class.video,
            showBackButton: true,
            bottomWidgets: [
              BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(builder: (context, subscribedCourseUsersState) {
                if (subscribedCourseUsersState is SubscribedCourseUsersSuccess) {
                  final int favorites =
                      subscribedCourseUsersState.favoriteUsers != null ? subscribedCourseUsersState.favoriteUsers.length : 0;
                  final int normalUsers = subscribedCourseUsersState.users != null ? subscribedCourseUsersState.users.length : 0;
                  final int qty = favorites + normalUsers;
                  return CourseInfoSection(
                      onAudioPressed: () => _coaches.isNotEmpty ? _audioAction() : null,
                      peopleQty: qty,
                      onPeoplePressed: () => _peopleAction(subscribedCourseUsersState.users, subscribedCourseUsersState.favoriteUsers),
                      audioMessageQty: AudioService.getAudiosLength(_audios),
                      image: OlukoNeumorphism.isNeumorphismDesign ? widget.classImage : widget.courseEnrollment.course.image);
                } else {
                  return CourseInfoSection(
                      onAudioPressed: () => _coaches.isNotEmpty ? _audioAction() : null,
                      peopleQty: 0,
                      audioMessageQty: AudioService.getAudiosLength(_audios),
                      image: OlukoNeumorphism.isNeumorphismDesign ? widget.classImage : widget.courseEnrollment.course.image);
                }
              })
            ],
            onBackPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.root], arguments: {
                'index': widget.courseIndex,
                'classIndex': widget.classIndex,
              });
            },
          )),
      Padding(
          padding: EdgeInsets.only(right: 15, left: 15, top: 25),
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: OlukoNeumorphism.isNeumorphismDesign
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            _class.name,
                            style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          widget.courseEnrollment.course.name,
                          style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.yellow),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: _startButton(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 10),
                        child: Text(
                          TimeConverter.toClassProgress(widget.classIndex, widget.courseEnrollment.classes.length, context),
                          style: OlukoFonts.olukoMediumFont(
                              custoFontWeight: FontWeight.normal,
                              customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.yellow : OlukoColors.primary),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: CourseProgressBar(
                              value: CourseEnrollmentService.getClassProgress(widget.courseEnrollment, widget.classIndex))),
                      (() {
                        // your code here
                        if (_class.description != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              _class.description,
                              style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      }()),
                      buildChallengeSection(),
                      classMovementSection(),
                    ])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _startButton(),
                      Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            _class.name,
                            style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 10),
                        child: Text(
                          TimeConverter.toClassProgress(widget.classIndex, widget.courseEnrollment.classes.length, context),
                          style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: CourseProgressBar(
                              value: CourseEnrollmentService.getClassProgress(widget.courseEnrollment, widget.classIndex))),
                      (() {
                        // your code here
                        if (_class.description != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              _class.description,
                              style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      }()),
                      buildChallengeSection(),
                      classMovementSection(),
                    ]))),
    ]);
  }

  BlocListener<InsideClassContentBloc, InsideClassContentState> slidingUpPanelComponent(BuildContext context) {
    return BlocListener<InsideClassContentBloc, InsideClassContentState>(
      listener: (context, state) {},
      child: SlidingUpPanel(
        onPanelClosed: () {
          BlocProvider.of<InsideClassContentBloc>(context).emitDefaultState();
        },
        backdropEnabled: true,
        isDraggable: false,
        header: const SizedBox(),
        padding: EdgeInsets.zero,
        color: OlukoColors.black,
        minHeight: 0.0,
        maxHeight: 450, //TODO
        collapsed: const SizedBox(),
        controller: _buttonController,
        panel: BlocBuilder<InsideClassContentBloc, InsideClassContentState>(builder: (context, state) {
          Widget _contentForPanel = const SizedBox();
          if (state is InsideClassContentDefault) {
            if (_buttonController.isPanelOpen) {
              _buttonController.close();
            }
            _contentForPanel = const SizedBox();
          }
          if (state is InsideClassContentPeopleOpen) {
            _buttonController.open();
            _contentForPanel =
                ModalPeopleEnrolled(userId: widget.courseEnrollment.createdBy, users: state.users, favorites: state.favorites);
          }
          if (state is InsideClassContentAudioOpen) {
            _buttonController.open();
            _contentForPanel = ModalAudio(users: _coaches, audios: _audios);
          }
          if (state is InsideClassContentLoading) {
            _contentForPanel = UploadingModalLoader(UploadFrom.segmentDetail);
          }
          return _contentForPanel;
        }),
      ),
    );
  }

  _peopleAction(List<dynamic> users, List<dynamic> favorites) {
    BlocProvider.of<InsideClassContentBloc>(context).openPeoplePanel(users, favorites);
  }

  _audioAction() {
    BlocProvider.of<InsideClassContentBloc>(context).openAudioPanel();
  }
}
