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
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/friends_weight_records_bloc.dart';
import 'package:oluko_app/blocs/inside_class_content_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/statistics/statistics_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
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
import 'package:oluko_app/ui/newDesignComponents/oluko_text_component.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/ui/screens/courses/class_detail_section.dart';
import 'package:oluko_app/ui/screens/courses/course_info_section.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/challenge_utils.dart';
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
  List<UserResponse> favoriteUsers = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ClassBloc>(context).get(widget.courseEnrollment.classes[widget.classIndex].id);
    BlocProvider.of<SegmentBloc>(context).getSegmentsInClass(widget.courseEnrollment.classes[widget.classIndex]);
    BlocProvider.of<SubscribedCourseUsersBloc>(context).get(widget.courseEnrollment.course.id, widget.courseEnrollment.userId);
    BlocProvider.of<EnrollmentAudioBloc>(context).get(widget.courseEnrollment.id, widget.courseEnrollment.classes[widget.classIndex].id);
    BlocProvider.of<DownloadAssetBloc>(context).getVideo();
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
        return BlocBuilder<ClassBloc, ClassState>(
          builder: (context, state) {
            if (state is GetByIdSuccess) {
              _class = state.classObj;
              return WillPopScope(
                  onWillPop: () {
                    return _onBackButtonPress(context);
                  },
                  child: form());
            } else {
              return const FullScreenLoadingComponent();
            }
          },
        );
      } else {
        return const FullScreenLoadingComponent();
      }
    });
  }

  Future<bool> _onBackButtonPress(BuildContext context) {
    _buttonController?.close();
    _goBackToCourseDetails(context);
    return Future(() => false);
  }

  void _goBackToCourseDetails(BuildContext context) {
    BlocProvider.of<CourseHomeBloc>(context).getByCourseEnrollments([widget.courseEnrollment]);
    Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.courseHomePage], arguments: {
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
        child: Scaffold(
          body: Stack(
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
                  color: OlukoNeumorphismColors.appBackgroundColor,
                  child: classInfoSection(),
                ),
              ),
              slidingUpPanelComponent(context)
            ],
          ),
        ));
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
    _challengeNavigations = ChallengeUtils.getChallenges(_class, widget.courseEnrollment, widget.classIndex, widget.courseIndex);
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
          userRequested: currentUser,
          useAudio: false,
          segmentChallenge: challenges[i],
          navigateToSegment: true,
          challengeNavigations: _challengeNavigations,
          audioIcon: false,
          customValueForChallenge: _completedBefore[i]));
    }
    return challengeCards;
  }

  Widget classMovementSection() {
    _classMovements = ClassService.getClassMovementSubmodels(_class);
    return ClassMovementSection(
      panelController: panelController,
      movements: _classMovements,
      classObj: _class,
      onPressedMovement: () {
        closeVideo();
      },
    );
  }

  Widget panelDetail() {
    return BlocBuilder<SegmentBloc, SegmentState>(
      builder: (context, segmentState) {
        if (segmentState is GetSegmentsSuccess) {
          _classSegments = segmentState.segments;
          setCompletedBefore();
          return ClassDetailSection(
            challengeNavigations: _challengeNavigations,
            classObj: _class,
            segments: segmentState.segments,
            onPressedMovement: () {
              closeVideo();
            },
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              gradient: OlukoNeumorphism.olukoNeumorphicGradientDark(),
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

  Widget classInfoSection() {
    return ListView.builder(
      physics: OlukoNeumorphism.listViewPhysicsEffect,
      padding: EdgeInsets.zero,
      itemCount: 1,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            getNeumorphicVideoPreview(),
            Padding(
              padding: const EdgeInsets.only(right: 15, left: 15, top: 25),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: neumorphicBody(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget neumorphicBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OlukoTextComponent(
          textContent: _class.name,
          textStyle: OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.bold),
          elementPadding: const EdgeInsets.only(top: 15.0),
        ),
        OlukoTextComponent(
          textContent: widget.courseEnrollment.course.name,
          textStyle: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.yellow),
          elementPadding: const EdgeInsets.symmetric(vertical: 10.0),
        ),
        _usersDoingCourse(),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: _startButton(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 10),
          child: OlukoTextComponent(
            textContent: ClassUtils.toClassProgress(widget.classIndex, widget.courseEnrollment.classes.length, context),
            textStyle: OlukoFonts.olukoMediumFont(
              customFontWeight: FontWeight.normal,
              customColor: OlukoColors.yellow,
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
          OlukoTextComponent(
            textContent: _class.description,
            textStyle: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
            elementPadding: const EdgeInsets.only(top: 20.0),
          )
        else
          const SizedBox(),
        buildChallengeSection(),
        classMovementSection(),
      ],
    );
  }

  Row _usersDoingCourse() {
    return Row(
      children: [
        BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(
          builder: (context, subscribedCourseUsersState) {
            if (subscribedCourseUsersState is SubscribedCourseUsersSuccess) {
              final int favorites = subscribedCourseUsersState.favoriteUsers != null ? subscribedCourseUsersState.favoriteUsers.length : 0;
              final int normalUsers = subscribedCourseUsersState.users != null ? subscribedCourseUsersState.users.length : 0;
              final int qty = favorites + normalUsers;
              favoriteUsers = subscribedCourseUsersState.favoriteUsers;
              return GestureDetector(
                onTap: () => _peopleAction(subscribedCourseUsersState.users, favoriteUsers),
                child: OlukoTextComponent(
                  textContent: '$qty+',
                  textAlignment: TextAlign.center,
                  textStyle: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold),
                ),
              );
            } else if (subscribedCourseUsersState is StatisticsLoading) {
              return Center(child: OlukoCircularProgressIndicator());
            } else {
              return OlukoTextComponent(
                textContent: '0+',
                textAlignment: TextAlign.center,
                textStyle: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold),
              );
            }
          },
        ),
        const SizedBox(
          width: 8,
        ),
        OlukoTextComponent(
          textContent: widget.courseEnrollment.course.name,
          textStyle: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
          elementPadding: const EdgeInsets.symmetric(vertical: 10.0),
        ),
      ],
    );
  }

  Widget getNeumorphicVideoPreview() {
    final String _classImage = widget.courseEnrollment.classes[widget.classIndex].image;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: OlukoVideoPreview(
          randomImages: widget.actualCourse?.userSelfies ?? [],
          video: VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: _class.videoHls, videoUrl: _class.video),
          showBackButton: true,
          audioWidget: OlukoNeumorphism.isNeumorphismDesign ? _getAudioWidget() : null,
          bottomWidgets: [_getCourseInfoSection(_classImage)],
          onBackPressed: () => _goBackToCourseDetails(context),
          onPlay: () => isVideoPlaying(),
          videoVisibilty: _isVideoPlaying,
          isGreenButton: true),
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
        color: Colors.transparent,
        minHeight: 0.0,
        maxHeight: 450,
        collapsed: const SizedBox(),
        controller: _buttonController,
        panel: peopleInsideCourse(),
      ),
    );
  }

  BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState> peopleInsideCourse() {
    return BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(
      builder: (context, subscribedUsersState) {
        return BlocBuilder<InsideClassContentBloc, InsideClassContentState>(builder: (context, state) {
          Widget _contentForPanel = const SizedBox();
          if (state is InsideClassContentDefault) {
            if (_buttonController.isPanelOpen) {
              _buttonController.close();
            }
            _contentForPanel = const SizedBox();
          }
          if (state is InsideClassContentPeopleOpen) {
            if (subscribedUsersState is SubscribedCourseUsersSuccess) {
              _buttonController.open();
              _contentForPanel = ModalPeopleEnrolled(
                userId: widget.courseEnrollment.createdBy,
                users: subscribedUsersState.users,
                favorites: subscribedUsersState.favoriteUsers,
                userProgressStreamBloc: BlocProvider.of<UserProgressStreamBloc>(context),
                userProgressListBloc: BlocProvider.of<UserProgressListBloc>(context),
                blocFavoriteFriend: BlocProvider.of<FavoriteFriendBloc>(context),
                blocFriends: BlocProvider.of<FriendBloc>(context),
                blocHifiveReceived: BlocProvider.of<HiFiveReceivedBloc>(context),
                blocPointsCard: BlocProvider.of<PointsCardBloc>(context),
                blocHifiveSend: BlocProvider.of<HiFiveSendBloc>(context),
                blocUserStatistics: BlocProvider.of<UserStatisticsBloc>(context),
                friendRequestBloc: BlocProvider.of<FriendRequestBloc>(context),
              );
            } else {
              _buttonController.open();
              _contentForPanel = Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [OlukoNeumorphismColors.initialGradientColorDark, OlukoNeumorphismColors.finalGradientColorDark],
                      ),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ));
            }
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
        });
      },
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
          favoriteUsers = subscribedCourseUsersState.favoriteUsers;
          return CourseInfoSection(
            onAudioPressed: () => _coaches.isNotEmpty ? _audioAction() : null,
            peopleQty: qty,
            onPeoplePressed: () => _peopleAction(subscribedCourseUsersState.users, favoriteUsers),
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
    return BlocBuilder<EnrollmentAudioBloc, EnrollmentAudioState>(
      builder: (context, enrollmentAudioState) {
        return BlocBuilder<ClassBloc, ClassState>(
          builder: (context, classState) {
            if (classState is GetByIdSuccess && enrollmentAudioState is GetEnrollmentAudioSuccess) {
              _enrollmentAudio = enrollmentAudioState.enrollmentAudio;
              _class = classState.classObj;
              List<Audio> classAudios = enrollmentAudioState?.enrollmentAudio?.audios ?? [];
              _audios = AudioService.getNotDeletedAudios(classAudios);
              _audioQty = _audios == null ? 0 : _audios.where((element) => element.seen == false).length;
              BlocProvider.of<CoachAudioBloc>(context).getByAudios(_audios);
            }
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
          },
        );
      },
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
          'fromChallenge': false,
          'actualCourse': widget.actualCourse,
          'favoriteUsers': favoriteUsers
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
      ),
      const SizedBox(width: 25),
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
    ];
  }
}
