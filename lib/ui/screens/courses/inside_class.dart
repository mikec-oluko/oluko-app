import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_completed_before_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_audio_bloc.dart';
import 'package:oluko_app/blocs/download_assets_bloc.dart';
import 'package:oluko_app/blocs/enrollment_audio_bloc.dart';
import 'package:oluko_app/blocs/friends/common_friend_panel_bloc.dart';
import 'package:oluko_app/blocs/inside_class_content_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
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
import 'package:oluko_app/ui/newDesignComponents/full_screen_loading_component.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
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
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum PanelEnum { audios, classDetail }

class InsideClass extends StatefulWidget {
  InsideClass({
    this.courseEnrollment,
    this.classIndex,
    this.courseIndex,
    this.actualCourse,
    Key key,
  }) : super(key: key);
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int courseIndex;
  final Course actualCourse;

  @override
  _InsideClassesState createState() => _InsideClassesState();
}

class _InsideClassesState extends State<InsideClass> {
  final _formKey = GlobalKey<FormState>();
  Class _class;
  PanelController panelController = PanelController();
  final PanelController _buttonController = PanelController();
  List<MovementSubmodel> _classMovements;
  List<UserResponse> _coaches;
  List<Audio> _audios = [];
  AudioPlayer audioPlayer = AudioPlayer();
  EnrollmentAudio _enrollmentAudio;
  int _audioQty = 0;
  bool _isVideoPlaying = false;
  Widget panelContent;
  PanelEnum panelState;
  List<Segment> _classSegments;
  List<ChallengeNavigation> _challengeNavigations = [];
  List<bool> _completedBefore = [];
  UserResponse currentUser;
  AuthSuccess currentAuthState;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<DownloadAssetBloc>(context).getVideo();
    BlocProvider.of<ClassBloc>(context).get(widget.courseEnrollment.classes[widget.classIndex].id);
    BlocProvider.of<SegmentBloc>(context).getSegmentsInClass(widget.courseEnrollment.classes[widget.classIndex]);
    BlocProvider.of<EnrollmentAudioBloc>(context).get(widget.courseEnrollment.id, widget.courseEnrollment.classes[widget.classIndex].id);
    BlocProvider.of<SubscribedCourseUsersBloc>(context).get(widget.courseEnrollment.course.id, widget.courseEnrollment.userId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        currentUser = authState.user;
        currentAuthState = authState;
        return BlocBuilder<EnrollmentAudioBloc, EnrollmentAudioState>(builder: (context, enrollmentAudioState) {
          return BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
            if (classState is GetByIdSuccess && enrollmentAudioState is GetEnrollmentAudioSuccess) {
              _enrollmentAudio = enrollmentAudioState.enrollmentAudio;
              _class = classState.classObj;
              List<Audio> classAudios = enrollmentAudioState?.enrollmentAudio?.audios ?? [];
              _audios = AudioService.getNotDeletedAudios(classAudios);
              _audioQty = _audios == null ? 0 : _audios.where((element) => element.seen == false).length;
              BlocProvider.of<CoachAudioBloc>(context).getByAudios(_audios);
              return WillPopScope(
                  onWillPop: () {
                    return _onBackButtonPress(context);
                  },
                  child: form());
            } else {
              return const FullScreenLoadingComponent();
            }
          });
        });
      } else {
        return const SizedBox();
      }
    });
  }

  Future<bool> _onBackButtonPress(BuildContext context) {
    _buttonController?.close();
    _goBackToCourseDetails(context);
    return Future(() => false);
  }

  //TODO: CHECK NAVIGATION
  void _goBackToCourseDetails(BuildContext context) {
    BlocProvider.of<CourseHomeBloc>(context).getByCourseEnrollments([widget.courseEnrollment]);
    Navigator.popAndPushNamed(context, routeLabels[RouteEnum.courseHomePage], arguments: {
      'courseEnrollments': [widget.courseEnrollment],
      'authState': currentAuthState,
      'courses': [widget.actualCourse],
      'user': currentUser,
      'isFromHome': true
    });
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Scaffold(body: BlocBuilder<CoachAudioBloc, CoachAudioState>(
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
                    color: OlukoColors.black,
                  ),
                  panel: panelDetail(),
                  body: Container(
                    color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColorFadeBottom : OlukoColors.black,
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
      )),
    );
  }

  void closeVideo() {
    if (_isVideoPlaying) {
      setState(() {
        _isVideoPlaying = !_isVideoPlaying;
      });
    }
  }

  Widget _startButton() {
    return BlocBuilder<SegmentBloc, SegmentState>(builder: (context, segmentState) {
      if (segmentState is GetSegmentsSuccess) {
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
      } else {
        return OlukoCircularProgressIndicator();
      }
    });
  }

  Widget buildChallengeSection() {
    _challengeNavigations = getChallenges();
    if (_challengeNavigations.isNotEmpty) {
      BlocProvider.of<ChallengeCompletedBeforeBloc>(context)
          .getChallengesAndCompletedBefore(userId: widget.courseEnrollment.userId, listOfChallenges: _challengeNavigations);
      return BlocBuilder<ChallengeCompletedBeforeBloc, ChallengeCompletedBeforeState>(
        builder: (context, state) {
          if (state is ChallengeCompletedSuccess) {
            _completedBefore = state.completedBefore;
            return ChallengeSection(challengesCard: buildChallengeCards(_challengeNavigations));
          } else {
            return Column(children: [
              const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: OlukoNeumorphicDivider(
                    isFadeOut: true,
                  )),
              OlukoCircularProgressIndicator()
            ]);
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }

  List<Widget> buildChallengeCards(List<ChallengeNavigation> challenges) {
    List<Widget> challengeCards = [];
    for (int i = 0; i < _completedBefore.length; i++) {
      challengeCards.add(ChallengesCard(
          userRequested: null,
          useAudio: false,
          segmentChallenge: challenges[i],
          navigateToSegment: true,
          audioIcon: false,
          customValueForChallenge: _completedBefore[i]));
    }
    return challengeCards;
  }

  List<ChallengeNavigation> getChallenges() {
    List<SegmentSubmodel> challenges = [];
    List<ChallengeNavigation> challengesForNavigation = [];
    _class.segments.forEach((SegmentSubmodel segment) {
      if (segment.image != null && segment.isChallenge) {
        int segmentPos = _class.segments.indexOf(segment);

        SegmentSubmodel previousSegment = segmentPos > 0 ? _class.segments.elementAt(segmentPos - 1) : null;

        EnrollmentClass classWithSegments = widget.courseEnrollment.classes.where((actualClass) => actualClass.id == _class.id).toList().first;
        List<EnrollmentSegment> segmentFromClass = classWithSegments.segments.where((segmentElement) => segmentElement.id == segment.id).toList();
        if (segmentFromClass.isNotEmpty) {
          setChallengeImageIfNotFound(segmentFromClass.first, segment);

          EnrollmentSegment lastSegment =
              previousSegment != null ? classWithSegments.segments.where((segmentElement) => segmentElement.id == previousSegment.id).toList().first : null;

          challengesForNavigation.add(createChallengeForNavigation(
            segmentFromCourseEnrollment: segmentFromClass.first,
            classFromCourseEnrollment: classWithSegments,
            previousSegmentFinished: previousSegment != null ? lastSegment.completedAt != null : true,
            segmentIndex: classWithSegments.segments.indexOf(segmentFromClass.first),
            segmentId: segmentFromClass.first.id,
            classId: classWithSegments.id,
          ));
        }
      }
    });
    return challengesForNavigation;
  }

  void setChallengeImageIfNotFound(EnrollmentSegment segmentFromClass, SegmentSubmodel segment) {
    segmentFromClass.image ??= segment.image;
  }

  ChallengeNavigation createChallengeForNavigation({
    @required EnrollmentSegment segmentFromCourseEnrollment,
    @required EnrollmentClass classFromCourseEnrollment,
    @required bool previousSegmentFinished,
    @required int segmentIndex,
    @required String segmentId,
    @required String classId,
  }) {
    ChallengeNavigation _newChallengeNavigation = ChallengeNavigation(
        enrolledCourse: widget.courseEnrollment,
        challengeSegment: segmentFromCourseEnrollment,
        segmentIndex: segmentIndex,
        segmentId: segmentId,
        classIndex: widget.classIndex,
        classId: classId,
        courseIndex: widget.courseIndex,
        previousSegmentFinish: previousSegmentFinished);

    return _newChallengeNavigation;
  }

  Widget classMovementSection() {
    _classMovements = ClassService.getClassMovementSubmodels(_class);
    return ClassMovementSection(
      panelController: panelController,
      movements: _classMovements,
      classObj: _class,
      onPressedMovement: (BuildContext context, MovementSubmodel movement) {
        closeVideo();
        Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': movement});
      },
    );
  }

  Widget panelDetail() {
    return BlocBuilder<SegmentBloc, SegmentState>(
      builder: (context, segmentState) {
        if (segmentState is GetSegmentsSuccess) {
          _classSegments = segmentState.segments;
          setCompletedBefore();
          return ClassDetailSection(challengeNavigations: _challengeNavigations, classObj: _class, segments: segmentState.segments);
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

  void setCompletedBefore() {
    for (int i = 0; i < _completedBefore.length; i++) {
      _challengeNavigations[i].previousSegmentFinish = _completedBefore[i];
    }
  }

  Widget classInfoSection(List<UserResponse> coaches) {
    return ListView(
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      children: [
        if (OlukoNeumorphism.isNeumorphismDesign) getNeumorphicVideoPreview() else getVideoPreview(),
        Padding(
          padding: const EdgeInsets.only(right: 15, left: 15, top: 25),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: OlukoNeumorphism.isNeumorphismDesign ? neumorphicBody() : body(),
          ),
        ),
      ],
    );
  }

  Widget body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _startButton(),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            _class.name,
            style: OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 10),
          child: Text(
            ClassUtils.toClassProgress(widget.classIndex, widget.courseEnrollment.classes.length, context),
            style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
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
                style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
              ),
            );
          } else {
            return const SizedBox();
          }
        }()),
        buildChallengeSection(),
        classMovementSection(),
      ],
    );
  }

  Widget neumorphicBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            _class.name,
            style: OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            widget.courseEnrollment.course.name,
            style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.yellow),
          ),
        ),
        Row(
          children: [
            BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(
              builder: (context, subscribedCourseUsersState) {
                if (subscribedCourseUsersState is SubscribedCourseUsersSuccess) {
                  final int favorites = subscribedCourseUsersState.favoriteUsers != null ? subscribedCourseUsersState.favoriteUsers.length : 0;
                  final int normalUsers = subscribedCourseUsersState.users != null ? subscribedCourseUsersState.users.length : 0;
                  final int qty = favorites + normalUsers;
                  return GestureDetector(
                    onTap: () => _peopleAction(subscribedCourseUsersState.users, subscribedCourseUsersState.favoriteUsers),
                    child: Text(
                      '$qty+',
                      textAlign: TextAlign.center,
                      style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  return Text(
                    '0+',
                    textAlign: TextAlign.center,
                    style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold),
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
                style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
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
              customFontWeight: FontWeight.normal,
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
        if (_class.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              _class.description,
              style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
            ),
          )
        else
          const SizedBox(),
        buildChallengeSection(),
        classMovementSection(),
      ],
    );
  }

  Widget getVideoPreview() {
    final String _classImage = widget.courseEnrollment.classes[widget.classIndex].image;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: OverlayVideoPreview(
        // video: _class.video,
        video: _class.videoHls ?? _class.video,
        showBackButton: true,
        audioWidget: OlukoNeumorphism.isNeumorphismDesign ? _getAudioWidget() : null,
        bottomWidgets: [_getCourseInfoSection(_classImage)],
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget getNeumorphicVideoPreview() {
    final String _classImage = widget.courseEnrollment.classes[widget.classIndex].image;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: OlukoVideoPreview(
        randomImages: widget.actualCourse?.userSelfies ?? [],
        video: VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: _class.videoHls, videoUrl: _class.video),
        // video: _class.video,
        showBackButton: true,
        audioWidget: OlukoNeumorphism.isNeumorphismDesign ? _getAudioWidget() : null,
        bottomWidgets: [_getCourseInfoSection(_classImage)],
        onBackPressed: () => _goBackToCourseDetails(context), // Navigator.pop(context),
        onPlay: () => isVideoPlaying(),
        videoVisibilty: _isVideoPlaying,
      ),
    );
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
            _contentForPanel = ModalPeopleEnrolled(
                userProgressStreamBloc: BlocProvider.of<UserProgressStreamBloc>(context),
                userId: widget.courseEnrollment.createdBy,
                users: state.users,
                favorites: state.favorites,
                userProgressListBloc: BlocProvider.of<UserProgressListBloc>(context));
          }
          if (state is InsideClassContentAudioOpen) {
            _buttonController.open();
            BlocProvider.of<EnrollmentAudioBloc>(context).markAudioAsSeen(_enrollmentAudio, _audios);
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
    BlocProvider.of<CourseEnrollmentAudioBloc>(context).markAudioAsDeleted(_enrollmentAudio, audiosUpdated, _audios);
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
              onTap: () => _audios.isNotEmpty ? _audioAction() : null,
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
          BlocBuilder<InsideClassContentBloc, InsideClassContentState>(
            buildWhen: (context, state) {
              return state is InsideClassContentAudioOpen || state is InsideClassContentLoading;
            },
            builder: (context, state) {
              if (state is InsideClassContentAudioOpen) {
                _audioQty = 0;
              }
              if (_audioQty > 0) {
                return Align(
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
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }

  void goToSegmentDetail() {
    closeVideo();
    int segmentIndex = CourseEnrollmentService.getFirstUncompletedSegmentIndex(widget.courseEnrollment.classes[widget.classIndex]);
    if (segmentIndex == -1 || widget.courseEnrollment.classes[widget.classIndex].completedAt != null) {
      segmentIndex = 0;
      showRedoDialog();
    } else {
      navigateToSegmentDetail(segmentIndex);
    }
  }

  void showRedoDialog() {
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
    ;
  }

  void navigateToSegmentDetail(int segmentIndex) {
    if (_classSegments != null) {
      Navigator.pushNamed(
        context,
        routeLabels[RouteEnum.segmentDetail],
        arguments: {
          'classSegments': _classSegments,
          'segmentIndex': segmentIndex,
          'classIndex': widget.classIndex,
          'courseEnrollment': widget.courseEnrollment,
          'courseIndex': widget.courseIndex,
          'fromChallenge': false
        },
      );
    }
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
            lighterButton: true,
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
              navigateToSegmentDetail(0);
            },
            title: OlukoLocalizations.get(context, 'yes'),
          ),
        )
      else
        OlukoPrimaryButton(
          title: OlukoLocalizations.get(context, 'yes'),
          onPressed: () {
            Navigator.pop(context);
            navigateToSegmentDetail(0);
          },
        ),
    ];
  }
}
