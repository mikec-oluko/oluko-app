import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_audio_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_completed_before_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_segment_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_stream_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/movement_weight_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/profile/max_weights_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/segment_detail_content_bloc.dart';
import 'package:oluko_app/blocs/segments/current_time_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/request_status_enum.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/coach_request_content.dart';
import 'package:oluko_app/ui/components/modal_audio.dart';
import 'package:oluko_app/ui/components/modal_people_enrolled.dart';
import 'package:oluko_app/ui/components/modal_personal_record.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/segment_image_section.dart';
import 'package:oluko_app/ui/components/segment_step_section.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:oluko_app/utils/timer_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SegmentDetail extends StatefulWidget {
  SegmentDetail(
      {this.classSegments,
      this.courseIndex,
      this.courseEnrollment,
      this.segmentIndex,
      this.classIndex,
      this.fromChallenge = false,
      this.favoriteUsers,
      this.actualCourse,
      Key key})
      : super(key: key);

  final CourseEnrollment courseEnrollment;
  final int segmentIndex;
  final int classIndex;
  final int courseIndex;
  final bool fromChallenge;
  List<Segment> classSegments;
  final Course actualCourse;
  final List<UserResponse> favoriteUsers;

  @override
  _SegmentDetailState createState() => _SegmentDetailState();
}

class _SegmentDetailState extends State<SegmentDetail> {
  final toolbarHeight = kToolbarHeight * 2;
  int currentSegmentStep;
  int segmentIndexSelected;
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
  bool isFinishedBefore = false;
  bool _canStartSegment = true;
  CoachRequest _coachRequest;
  ValueNotifier<int> dotsIndex;
  ValueNotifier<bool> panelState;
  bool _isVideoPlaying = false;
  bool showLowerWidgets = true;
  ChewieController chewieController;
  List<SegmentImageSection> carouselWidgets = [];
  GlobalService _globalService = GlobalService();
  final String _recordingNotificationSound = 'sounds/recording_notification.wav';

  @override
  void initState() {
    _coachRequests = [];
    segmentIndexToUse = widget.segmentIndex;
    currentSegmentStep = widget.segmentIndex + 1;
    segmentIndexSelected = segmentIndexToUse;
    dotsIndex = ValueNotifier(currentSegmentStep);
    panelState = ValueNotifier(showLowerWidgets);
    totalSegmentStep = widget.courseEnrollment.classes[widget.classIndex].segments.length;
    setSegments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.user;
        BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_user.id);
        BlocProvider.of<WorkoutWeightBloc>(context).getUserWeightsForWorkout(_user.id);
        BlocProvider.of<MaxWeightsBloc>(context).getUserMaxWeightRecords(_user.id);
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
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
      body: SizedBox(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        child: Stack(
          children: [imageSection(), _body(), slidingUpPanelComponent(), _segmentStepsDotsComponent(), _segmentStartButton()],
        ),
      ),
    );
  }

  Widget _body() {
    return widget.classSegments == null
        ? BlocBuilder<SegmentBloc, SegmentState>(builder: (context, segmentState) {
            if (segmentState is GetSegmentsSuccess) {
              _segments = segmentState.segments;
              widget.classSegments = segmentState.segments;
              setTotalSegments();
              _canStartSegment = canStartSegment(_segments);
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
      return Column(
        children: [if (_segments.length - 1 >= segmentIndexToUse) getCarouselSlider() else const SizedBox()],
      );
    });
  }

  Widget slidingUpPanelComponent() {
    return SlidingUpPanel(
      onPanelClosed: () {
        panelState.value = !panelState.value;
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
          users: state.users,
          blocFavoriteFriend: BlocProvider.of<FavoriteFriendBloc>(context),
          blocFriends: BlocProvider.of<FriendBloc>(context),
          blocHifiveReceived: BlocProvider.of<HiFiveReceivedBloc>(context),
          blocPointsCard: BlocProvider.of<PointsCardBloc>(context),
          blocHifiveSend: BlocProvider.of<HiFiveSendBloc>(context),
          blocUserStatistics: BlocProvider.of<UserStatisticsBloc>(context),
          friendRequestBloc: BlocProvider.of<FriendRequestBloc>(context),
        );
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

  bool canStartSegment(List<Segment> segments) {
    if (dotsIndex.value - 1 < 2) return true;
    if (segments != null && segments.isNotEmpty) {
      return segments[dotsIndex.value - 1].isChallenge
          ? widget.courseEnrollment.classes[widget.classIndex].segments[(dotsIndex.value - 2)].completedAt != null
          : true;
    }
    return false;
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
    int previousCarouselIndex = widget.segmentIndex;
    return Column(
      children: [
        topButtons(),
        _classTitleComponent(),
        Container(
          height: ScreenUtils.height(context) - 138,
          child: SlidingUpPanel(
            controller: panelController,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            minHeight: 90,
            maxHeight: 180,
            onPanelSlide: (value) => value > 0 ? panelState.value = false : panelState.value = true,
            collapsed: CollapsedMovementVideosSection(action: getAction()),
            panel: movementsPanel(),
            body: Column(
              children: [
                CarouselSlider(
                  items: getSegmentList(),
                  options: CarouselOptions(
                    onPageChanged: (index, reason) {
                      final SegmentImageSection imageSection = carouselWidgets.firstWhere((element) => element.currentSegmentStep == dotsIndex.value);
                      dotsIndex.value = index + 1;
                      segmentIndexSelected = dotsIndex.value - 1;
                      imageSection.changeVideoState();
                      if (widget.classSegments[index].isChallenge) {
                        _canStartSegment = canStartSegment(_segments);
                        BlocProvider.of<ChallengeCompletedBeforeBloc>(context)
                            .completedChallengeBefore(segmentId: widget.classSegments[index].id, userId: _user.id);
                      }
                    },
                    height: ScreenUtils.height(context),
                    disableCenter: true,
                    enableInfiniteScroll: false,
                    initialPage: segmentIndexToUse,
                    viewportFraction: 0.85,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Positioned _segmentStartButton() {
    return Positioned(
        bottom: ScreenUtils.height(context) * 0.15,
        child: Align(
            child: SizedBox(
                width: ScreenUtils.width(context),
                child: BlocBuilder<SegmentBloc, SegmentState>(
                  builder: (context, segmentState) {
                    if (segmentState is GetSegmentsSuccess) {
                      return BlocBuilder<ChallengeCompletedBeforeBloc, ChallengeCompletedBeforeState>(builder: (context, state) {
                        if (state is ChallengeHistoricalResult) {
                          isFinishedBefore = state.wasCompletedBefore;
                          _canStartSegment = isFinishedBefore ? isFinishedBefore : _canStartSegment;
                        }
                        return ValueListenableBuilder(
                          valueListenable: panelState,
                          builder: (context, panelStates, child) {
                            if (panelStates as bool && widget.classSegments != null) {
                              return ValueListenableBuilder(
                                  valueListenable: dotsIndex,
                                  builder: (context, panelStates, child) {
                                    return startWorkoutsButton(isFinishedBefore);
                                  });
                            }
                            return SizedBox();
                          },
                        );
                      });
                    }
                    return SizedBox();
                  },
                ))));
  }

  Widget _segmentStepsDotsComponent() => Positioned(
      bottom: ScreenUtils.height(context) * 0.22,
      left: 50,
      right: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: panelState,
            builder: (context, state, child) {
              if (state as bool) {
                return ValueListenableBuilder(
                  valueListenable: dotsIndex,
                  builder: (context, index, child) {
                    return SegmentStepSection(currentSegmentStep: index as int, totalSegmentStep: totalSegmentStep);
                  },
                );
              } else
                return SizedBox();
            },
          ),
        ],
      ));
  Widget topButtons() {
    EdgeInsetsGeometry padding;
    if (_coachRequests != null) {
      padding = const EdgeInsets.only(top: OlukoNeumorphism.buttonBackPaddingFromTop, left: 15);
    } else {
      padding = const EdgeInsets.only(top: OlukoNeumorphism.buttonBackPaddingFromTop, left: 15, right: 20);
    }
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (!OlukoNeumorphism.isNeumorphismDesign)
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                onPressedAction();
              },
            )
          else
            OlukoNeumorphicCircleButton(
              onPressed: () {
                Navigator.pop(context);
                onPressedAction();
              },
            ),
          const Expanded(child: SizedBox()),
          if (!_isVideoPlaying)
            const SizedBox()
          else
            GestureDetector(
              onTap: () => changeVideoState(),
              child: SizedBox(
                height: 46,
                width: 46,
                child: OlukoBlurredButton(
                  childContent: Image.asset(
                    'assets/courses/white_cross.png',
                    scale: 3.5,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget startWorkoutsButton(bool isFinishedBefore) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? ((widget.classSegments[dotsIndex.value - 1].isChallenge && _canStartSegment) ||
                ((widget.classSegments[dotsIndex.value - 1].isChallenge && isFinishedBefore) || !widget.classSegments[dotsIndex.value - 1].isChallenge))
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtils.width(context) * 0.14),
                child: OlukoNeumorphicPrimaryButton(
                  useBorder: true,
                  thinPadding: true,
                  isExpanded: false,
                  title: OlukoNeumorphism.isNeumorphismDesign ? OlukoLocalizations.get(context, 'start') : OlukoLocalizations.get(context, 'startWorkout'),
                  onPressed: () {
                    BlocProvider.of<CurrentTimeBloc>(context).setCurrentTimeNull();
                    navigateToSegmentWithoutRecording();
                  },
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtils.width(context) * 0.14),
                child: OlukoNeumorphicPrimaryButton(
                  useBorder: true,
                  thinPadding: true,
                  isExpanded: false,
                  isDisabled: true,
                  title: OlukoLocalizations.get(context, 'locked'),
                  onPressed: () {},
                ),
              )
        : Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OlukoPrimaryButton(
                  title: OlukoNeumorphism.isNeumorphismDesign ? OlukoLocalizations.get(context, 'start') : OlukoLocalizations.get(context, 'startWorkout'),
                  color: OlukoColors.primary,
                  onPressed: () {
                    BlocProvider.of<CurrentTimeBloc>(context).setCurrentTimeNull();

                    if (_coachRequest != null) {
                      showCoachDialog();
                    } else {
                      navigateToSegmentWithoutRecording();
                    }
                  },
                )
              ],
            ),
          );
  }

  void showCoachDialog() {
    BottomDialogUtils.showBottomDialog(
      context: context,
      content: CoachRequestContent(
        name: _coach.firstName,
        image: _coach.avatar,
        onNotRecordingAction: navigateToSegmentWithoutRecording,
        onRecordingAction: navigateToSegmentWithRecording,
      ),
    );
  }

  navigateToSegmentWithRecording() {
    if (_globalService.videoProcessing) {
      DialogUtils.getDialog(
          context,
          [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  OlukoLocalizations.get(context, 'videoIsStillProcessing'),
                  textAlign: TextAlign.center,
                  style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                ))
          ],
          showExitButton: true);
    } else {
      Navigator.pushNamed(
        context,
        routeLabels[RouteEnum.segmentCameraPreview],
        arguments: {
          'segmentIndex': currentSegmentStep - 1,
          'classIndex': widget.classIndex,
          'coach': _coach,
          'courseEnrollment': widget.courseEnrollment,
          'courseIndex': widget.courseIndex,
          'segments': _segments,
        },
      );
    }
  }

  navigateToSegmentWithoutRecording() async {
    if ((nextIsLastOne() && widget.classSegments[segmentIndexSelected].rounds == 1) &&
        getSegmentCoachRequest(widget.classSegments[segmentIndexSelected].id) != null) {
      BottomDialogUtils.showBottomDialog(
        backgroundTapEnable: false,
        context: context,
        content: CoachRequestContent(
          name: _coach?.firstName ?? '',
          image: _coach?.avatar,
          onNotificationDismiss: () {
            Navigator.pop(context);
            TimerUtils.startCountdown(WorkoutType.segment, context, getArguments(), widget.classSegments[segmentIndexSelected].initialTimer);
            BlocProvider.of<CoachRequestStreamBloc>(context).resolve(_coachRequest, widget.courseEnrollment.userId, RequestStatusEnum.ignored);
          },
          isNotification: true,
        ),
      );
      await SoundPlayer().playAsset(asset: _recordingNotificationSound, isForWatch: true);
    } else {
      TimerUtils.startCountdown(WorkoutType.segment, context, getArguments(), widget.classSegments[segmentIndexSelected].initialTimer);
      BlocProvider.of<CoachRequestStreamBloc>(context).resolve(_coachRequest, widget.courseEnrollment.userId, RequestStatusEnum.ignored);
    }
  }

  bool nextIsLastOne() {
    SegmentUtils.getExercisesList(widget.classSegments[segmentIndexSelected]);
    return widget.classSegments[segmentIndexSelected].sections.length == SegmentUtils.getExercisesList(widget.classSegments[segmentIndexSelected]).length - 1;
  }

  CoachRequest getSegmentCoachRequest(String segmentId) {
    for (var i = 0; i < _coachRequests.length; i++) {
      if (_coachRequests[i].segmentId == segmentId) {
        return _coachRequests[i];
      }
    }
    return null;
  }

  Object getArguments() {
    return {
      'segmentIndex': dotsIndex.value - 1,
      'classIndex': widget.classIndex,
      'courseEnrollment': widget.courseEnrollment,
      'courseIndex': widget.courseIndex,
      'workoutType': WorkoutType.segment,
      'coach': _coach,
      'segments': widget.classSegments,
      'fromChallenge': widget.fromChallenge,
      'coachRequest': _coachRequest
    };
  }

  Widget _classTitleComponent() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SizedBox(
            width: ScreenUtils.width(context) - 20,
            child: Text(
              _classTitle(),
              style: _classTitle().length > 25
                  ? OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold)
                  : OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  void changeVideoState() {
    setState(() {
      _isVideoPlaying = !_isVideoPlaying;
    });
  }

  String _classTitle() => widget.courseEnrollment.classes[widget.classIndex].name;
  List<Widget> getSegmentList() {
    List<Widget> segmentWidgets = [];
    for (var i = 0; i < _segments.length; i++) {
      segmentWidgets.add(Wrap(children: [
        getSegmentImageSection(i),
      ]));
    }
    return segmentWidgets;
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
              final SegmentImageSection segmentImageSection = SegmentImageSection(
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
                currentUser: _user,
                fromChallenge: widget.fromChallenge,
              );
              carouselWidgets.add(segmentImageSection);
              return ValueListenableBuilder(
                valueListenable: dotsIndex,
                builder: (context, index, child) {
                  return Opacity(
                    opacity: (index as int) == i + 1 ? 1 : 0.5,
                    child: segmentImageSection,
                  );
                },
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
            (_coach != null &&
                coachRequest.coachId == _coach.id &&
                coachRequest.courseEnrollmentId == widget.courseEnrollment.id &&
                coachRequest.classId == widget.courseEnrollment.classes[widget.classIndex].id))
        .toList();
    _coachRequest = getSegmentCoachRequest(widget.classSegments[currentSegmentStep - 1].id);
  }

  void onPressedAction() {
    if (widget.fromChallenge) {
      return;
    } else {
      Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.insideClass]));
      final arguments = {
        'courseEnrollment': widget.courseEnrollment,
        'classIndex': widget.classIndex,
        'courseIndex': widget.courseIndex,
        'actualCourse': widget.actualCourse,
      };
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

  Widget movementsPanel() {
    if (_segments.length - 1 >= segmentIndexToUse) {
      return ValueListenableBuilder(
        valueListenable: dotsIndex,
        builder: (context, index, child) {
          return MovementVideosSection(
              action: OlukoNeumorphism.isNeumorphismDesign ? SizedBox.shrink() : downButton(),
              segment: _segments[(index as int) - 1],
              onPressedMovement: (BuildContext context, MovementSubmodel movementSubmodel) {
                carouselWidgets[dotsIndex.value].changeVideoState();
                Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': movementSubmodel});
              });
        },
      );
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
    if (widget.classSegments != null && widget.classSegments.isNotEmpty) {
      _segments = widget.classSegments;
      setTotalSegments();
      _canStartSegment = canStartSegment(_segments);
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

  Widget imageSection() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
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
    return Stack(
      alignment: Alignment.center,
      children: [
        imageAspectRatio(),
      ],
    );
  }

  AspectRatio imageAspectRatio() {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: () {
        if (widget.courseEnrollment.course.image != null) {
          return Image(
            image: CachedNetworkImageProvider(widget.courseEnrollment.course.image),
            fit: BoxFit.cover,
          );
        } else {
          return nil;
        }
      }(),
    );
  }

  void _audioAction(List<Audio> audios, Challenge challenge) {
    if (audios != null) {
      panelState.value = !panelState.value;
    }
    BlocProvider.of<SegmentDetailContentBloc>(context).openAudioPanel(audios, challenge);
  }

  void _peopleAction(List<UserResponse> users, List<UserSubmodel> favorites) {
    panelState.value = !panelState.value;
    BlocProvider.of<SegmentDetailContentBloc>(context).openPeoplePanel(users, favorites);
  }

  void _clockAction(String segmentId) {
    panelState.value = !panelState.value;
    BlocProvider.of<SegmentDetailContentBloc>(context).openClockPanel(segmentId);
  }
}
