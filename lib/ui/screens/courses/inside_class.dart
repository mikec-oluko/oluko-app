import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_audio_bloc.dart';
import 'package:oluko_app/blocs/enrollment_audio_bloc.dart';
import 'package:oluko_app/blocs/inside_class_content_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/audio_service.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/ui/components/challenge_section.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/class_movements_section.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/modal_audio.dart';
import 'package:oluko_app/ui/components/modal_people_enrolled.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/ui/screens/courses/class_detail_section.dart';
import 'package:oluko_app/ui/screens/courses/course_info_section.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/class_utils.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum PanelEnum { audios, classDetail }

class InsideClass extends StatefulWidget {
  InsideClass({
    this.courseEnrollment,
    this.classIndex,
    this.courseIndex,
    Key key,
  }) : super(key: key);
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int courseIndex;

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
  AudioPlayer audioPlayer = AudioPlayer();
  EnrollmentAudio _enrollmentAudio;
  int _audioQty = 0;
  bool _isVideoPlaying = false;
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
        BlocProvider.of<ClassBloc>(context).get(widget.courseEnrollment.classes[widget.classIndex].id);
        BlocProvider.of<MovementBloc>(context).getAll();
        BlocProvider.of<EnrollmentAudioBloc>(context).get(widget.courseEnrollment.id);
        return BlocBuilder<EnrollmentAudioBloc, EnrollmentAudioState>(builder: (context, enrollmentAudioState) {
          return BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
            if (classState is GetByIdSuccess && enrollmentAudioState is GetEnrollmentAudioSuccess) {
              _enrollmentAudio = enrollmentAudioState.enrollmentAudio;
              _class = classState.classObj;
              List<Audio> classAudios =
                  AudioService.getClassAudios(enrollmentAudioState.enrollmentAudio, widget.courseEnrollment.classes[widget.classIndex].id);
              _audios = AudioService.getNotDeletedAudios(classAudios);
              _audioQty = _audios == null ? 0 : _audios.length;
              BlocProvider.of<SegmentBloc>(context).getAll(_class);
              BlocProvider.of<CoachAudioBloc>(context).getByAudios(_audios);
              BlocProvider.of<SubscribedCourseUsersBloc>(context).get(widget.courseEnrollment.course.id, authState.user.id);
              return WillPopScope(
                  onWillPop: () {
                    _buttonController.close();
                    return Future(() => false);
                  },
                  child: form());
            } else {
              return OlukoCircularProgressIndicator();
            }
          });
        });
      } else {
        return const SizedBox();
      }
    });
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: BlocBuilder<MovementBloc, MovementState>(
          builder: (context, movementState) {
            if (movementState is GetAllSuccess) {
              _movements = movementState.movements;
              return BlocBuilder<CoachAudioBloc, CoachAudioState>(
                builder: (context, coachState) {
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
                          ),
                        ),
                        slidingUpPanelComponent(context)
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }
    widgets.add(
      OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => this.setState(() {
          _controller = chewieController;
        }),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).orientation == Orientation.portrait
            ? ScreenUtils.height(context) / 4
            : ScreenUtils.height(context) / 1.5,
        minHeight: MediaQuery.of(context).orientation == Orientation.portrait
            ? ScreenUtils.height(context) / 4
            : ScreenUtils.height(context) / 1.5,
      ),
      child: SizedBox(height: 400, child: Stack(children: widgets)),
    );
  }

  void closeVideo() {
    setState(() {
      if (_isVideoPlaying) {
        _isVideoPlaying = !_isVideoPlaying;
      }
    });
  }

  Widget _startButton() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: ScreenUtils.width(context) - 40,
                child: OlukoNeumorphicPrimaryButton(
                  isExpanded: false,
                  thinPadding: true,
                  title: OlukoLocalizations.get(context, 'start'),
                  onPressed: () => goToSegmentDetail(),
                ),
              )
            ],
          )
        : Row(
            children: [
              OlukoPrimaryButton(
                title: OlukoLocalizations.get(context, 'start'),
                onPressed: () => goToSegmentDetail(),
              ),
            ],
          );
  }

  Widget buildChallengeSection() {
    final List<SegmentSubmodel> challenges = getChallenges();
    if (challenges.isNotEmpty) {
      return ChallengeSection(
        challengesCard: getChallengesCard(),
      );
    } else {
      return const SizedBox();
    }
  }

  List<SegmentSubmodel> getChallenges() {
    List<SegmentSubmodel> challenges = [];
    _class.segments.forEach((SegmentSubmodel segment) {
      if (segment.image != null) {
        challenges.add(segment);
      }
    });
    return challenges;
  }

  List<Widget> getChallengesCard() {
    ChallengeNavigation segmentChallenge =
        ChallengeNavigation(enrolledCourse: widget.courseEnrollment, classIndex: widget.classIndex, courseIndex: widget.courseIndex);
    List<Widget> challengesCard = [];
    _class.segments.forEach((SegmentSubmodel segment) {
      if (segment.image != null) {
        for (int j = 0; j < widget.courseEnrollment.classes.length; j++) {
          if (widget.courseEnrollment.classes[j].id == _class.id) {
            for (int k = 0; k < widget.courseEnrollment.classes[j].segments.length; k++) {
              if (widget.courseEnrollment.classes[j].segments[k].id == segment.id) {
                if (k - 1 > 1) {
                  segmentChallenge.previousSegmentFinish = widget.courseEnrollment.classes[j].segments[k - 1].completedAt != null;
                  segmentChallenge.challengeSegment = widget.courseEnrollment.classes[j].segments[k];
                  segmentChallenge.segmentIndex = k;
                } else {
                  segmentChallenge.segmentIndex = k;
                  segmentChallenge.previousSegmentFinish = true;
                  segmentChallenge.challengeSegment = widget.courseEnrollment.classes[j].segments[k];
                }
              }
            }
          }
        }
        challengesCard.add(ChallengesCard(
          useAudio: false,
          segmentChallenge: segmentChallenge,
          navigateToSegment: true,
          audioIcon: false,
        ));
      }
    });

    return challengesCard;
  }

  Widget classMovementSection() {
    _classMovements = ClassService.getClassMovements(_class, _movements);
    return ClassMovementSection(
      panelController: panelController,
      movements: _classMovements,
      classObj: _class,
      onPressedMovement: (BuildContext context, Movement movement) {
        closeVideo();
        Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement});
      },
    );
  }

  Widget classDetailSection() {
    ChallengeNavigation segmentChallenge =
        ChallengeNavigation(enrolledCourse: widget.courseEnrollment, classIndex: widget.classIndex, courseIndex: widget.courseIndex);
    return BlocBuilder<SegmentBloc, SegmentState>(
      builder: (context, segmentState) {
        if (segmentState is GetSegmentsSuccess) {
          return ClassDetailSection(
              segmentChallenge: segmentChallenge, classObj: _class, movements: _movements, segments: segmentState.segments);
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/courses/gray_background.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: segmentState is LoadingSegment ? OlukoCircularProgressIndicator() : const SizedBox(),
          );
        }
      },
    );
  }

  Widget classInfoSection(List<UserResponse> coaches) {
    final String _classImage = widget.courseEnrollment.classes[widget.classIndex].image;
    return ListView(
      children: [
        if (OlukoNeumorphism.isNeumorphismDesign)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: OlukoVideoPreview(
              randomImages: _class.userSelfies,
              video: _class.video,
              showBackButton: true,
              audioWidget: OlukoNeumorphism.isNeumorphismDesign ? _getAudioWidget() : null,
              bottomWidgets: [_getCourseInfoSection(_classImage)],
              onBackPressed: () => Navigator.pop(context),
              onPlay: () => isVideoPlaying(),
              videoVisibilty: _isVideoPlaying,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: OverlayVideoPreview(
              video: _class.video,
              showBackButton: true,
              audioWidget: OlukoNeumorphism.isNeumorphismDesign ? _getAudioWidget() : null,
              bottomWidgets: [_getCourseInfoSection(_classImage)],
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 15, left: 15, top: 25),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: OlukoNeumorphism.isNeumorphismDesign
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          _class.name,
                          style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          widget.courseEnrollment.course.name,
                          style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.yellow),
                        ),
                      ),
                      Row(
                        children: [
                          BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(
                            builder: (context, subscribedCourseUsersState) {
                              if (subscribedCourseUsersState is SubscribedCourseUsersSuccess) {
                                final int favorites =
                                    subscribedCourseUsersState.favoriteUsers != null ? subscribedCourseUsersState.favoriteUsers.length : 0;
                                final int normalUsers =
                                    subscribedCourseUsersState.users != null ? subscribedCourseUsersState.users.length : 0;
                                final int qty = favorites + normalUsers;
                                return GestureDetector(
                                  onTap: () => _peopleAction(subscribedCourseUsersState.users, subscribedCourseUsersState.favoriteUsers),
                                  child: Text(
                                    '$qty+',
                                    textAlign: TextAlign.center,
                                    style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.bold),
                                  ),
                                );
                              } else {
                                return  Text(
                                  '0+',
                                  textAlign: TextAlign.center,
                                  style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.bold),
                                );
                              }
                            },
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              widget.courseEnrollment.course.name,
                              style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: _startButton(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 10),
                        child: Text(
                          ClassUtils.toClassProgress(widget.classIndex, widget.courseEnrollment.classes.length, context),
                          style: OlukoFonts.olukoMediumFont(
                            custoFontWeight: FontWeight.normal,
                            customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.yellow : OlukoColors.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: CourseProgressBar(
                          value: CourseEnrollmentService.getClassProgress(widget.courseEnrollment, widget.classIndex),
                        ),
                      ),
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
                          return const SizedBox();
                        }
                      }()),
                      buildChallengeSection(),
                      classMovementSection(),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _startButton(),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          _class.name,
                          style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 10),
                        child: Text(
                          ClassUtils.toClassProgress(widget.classIndex, widget.courseEnrollment.classes.length, context),
                          style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: CourseProgressBar(
                          value: CourseEnrollmentService.getClassProgress(widget.courseEnrollment, widget.classIndex),
                        ),
                      ),
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
                          return const SizedBox();
                        }
                      }()),
                      buildChallengeSection(),
                      classMovementSection(),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void pauseVideo() {
    if (_controller != null) {
      _controller.pause();
    }
  }

  void isVideoPlaying() {
    return setState(() {
      _isVideoPlaying = !_isVideoPlaying;
    });
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

            _contentForPanel = ModalAudio(
                panelController: _buttonController,
                users: _coaches,
                audios: _audios,
                onAudioPressed: (int index, Challenge challenge) => _onAudioDeleted(index, challenge),
                audioPlayer: audioPlayer);
          }
          if (state is InsideClassContentLoading) {
            _contentForPanel = UploadingModalLoader(UploadFrom.segmentDetail);
          }
          return _contentForPanel;
        }),
      ),
    );
  }

  _onAudioDeleted(int audioIndex, Challenge challenge) {
    _audios[audioIndex].deleted = true;
    List<Audio> audiosUpdated = _audios.toList();
    _audios.removeAt(audioIndex);
    BlocProvider.of<CourseEnrollmentAudioBloc>(context)
        .markAudioAsDeleted(_enrollmentAudio, audiosUpdated, widget.courseEnrollment.classes[widget.classIndex].id, _audios);
  }

  _peopleAction(List<dynamic> users, List<dynamic> favorites) {
    BlocProvider.of<InsideClassContentBloc>(context).openPeoplePanel(users, favorites);
  }

  _audioAction() {
    BlocProvider.of<InsideClassContentBloc>(context).openAudioPanel();
  }

  Widget _getCourseInfoSection(String classImage) {
    if (OlukoNeumorphism.isNeumorphismDesign) {
      return CourseInfoSection(
        image: OlukoNeumorphism.isNeumorphismDesign ? classImage : widget.courseEnrollment.course.image,
      );
    }
    return BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(
      builder: (context, subscribedCourseUsersState) {
        if (subscribedCourseUsersState is SubscribedCourseUsersSuccess) {
          final int favorites = subscribedCourseUsersState.favoriteUsers != null ? subscribedCourseUsersState.favoriteUsers.length : 0;
          final int normalUsers = subscribedCourseUsersState.users != null ? subscribedCourseUsersState.users.length : 0;
          final int qty = favorites + normalUsers;
          return CourseInfoSection(
            onAudioPressed: () => _coaches.isNotEmpty ? _audioAction() : null,
            peopleQty: qty,
            onPeoplePressed: () => _peopleAction(subscribedCourseUsersState.users, subscribedCourseUsersState.favoriteUsers),
            audioMessageQty: _audioQty,
            image: OlukoNeumorphism.isNeumorphismDesign ? classImage : widget.courseEnrollment.course.image,
          );
        } else {
          return CourseInfoSection(
            onAudioPressed: () => _coaches.isNotEmpty ? _audioAction() : null,
            peopleQty: 0,
            audioMessageQty: _audioQty,
            image: OlukoNeumorphism.isNeumorphismDesign ? classImage : widget.courseEnrollment.course.image,
          );
        }
      },
    );
  }

  Widget _getAudioWidget() {
    return SizedBox(
      height: 52,
      width: 52,
      child: Stack(
        children: [
          OlukoBlurredButton(
            childContent: GestureDetector(
              onTap: () => _audioQty > 0 ? _audioAction() : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Image.asset(
                      'assets/courses/audioNeumorphism.png',
                      height: 25,
                      width: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_audioQty > 0)
            Align(
              alignment: Alignment.topRight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/courses/audio_neumorphic_notification.png',
                    height: 18,
                    width: 18,
                  ),
                  Text(
                    _audioQty.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white),
                  ),
                ],
              ),
            )
          else
            const SizedBox()
        ],
      ),
    );
  }

  goToSegmentDetail() {
    int segmentIndex = CourseEnrollmentService.getFirstUncompletedSegmentIndex(widget.courseEnrollment.classes[widget.classIndex]);
    if (segmentIndex == -1 || widget.courseEnrollment.classes[widget.classIndex].completedAt != null) {
      segmentIndex = 0;
      if (OlukoNeumorphism.isNeumorphismDesign) {
        BottomDialogUtils.showBottomDialog(
          content: Container(
            height: ScreenUtils.height(context) * 0.35,
            decoration: const BoxDecoration(
              borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20)),
              image: DecorationImage(
                image: AssetImage('assets/courses/dialog_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: confirmationContent(),
          ),
          context: context,
        );
      } else {
        DialogUtils.getDialog(context, [confirmationContent()]);
      }
    } else {
      pushNamed(segmentIndex);
    }
  }

  void pushNamed(int segmentIndex) {
    Navigator.pushNamed(
      context,
      routeLabels[RouteEnum.segmentDetail],
      arguments: {
        'segmentIndex': segmentIndex,
        'classIndex': widget.classIndex,
        'courseEnrollment': widget.courseEnrollment,
        'courseIndex': widget.courseIndex,
        'fromChallenge': false
      },
    );
  }

  Widget confirmationContent() {
    return Padding(
      padding: OlukoNeumorphism.isNeumorphismDesign
          ? const EdgeInsets.symmetric(horizontal: 30, vertical: 25)
          : const EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              OlukoLocalizations.get(context, 'reDoCourseTitle'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              OlukoLocalizations.get(context, 'reDoCourseBody'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Colors.grey),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: getBottomButtons(),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getBottomButtons() {
    return [
      if (OlukoNeumorphism.isNeumorphismDesign)
        SizedBox(
          width: 80,
          child: OlukoNeumorphicSecondaryButton(
            isExpanded: false,
            thinPadding: true,
            textColor: Colors.grey,
            onPressed: () => Navigator.pop(context),
            title: OlukoLocalizations.get(context, 'no'),
          ),
        )
      else
        OlukoOutlinedButton(
          title: OlukoLocalizations.get(context, 'no'),
          thinPadding: true,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      const SizedBox(width: 25),
      if (OlukoNeumorphism.isNeumorphismDesign)
        SizedBox(
          width: 80,
          child: OlukoNeumorphicPrimaryButton(
            isExpanded: false,
            thinPadding: true,
            onPressed: () {
              Navigator.pop(context);
              pushNamed(0);
            },
            title: OlukoLocalizations.get(context, 'yes'),
          ),
        )
      else
        OlukoPrimaryButton(
          title: OlukoLocalizations.get(context, 'yes'),
          onPressed: () {
            Navigator.pop(context);
            pushNamed(0);
          },
        ),
    ];
  }
}
