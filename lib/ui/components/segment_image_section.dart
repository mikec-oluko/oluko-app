import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/challenge/challenge_audio_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_completed_before_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_stream_bloc.dart';
import 'package:oluko_app/blocs/done_challenge_users_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends_weight_records_bloc.dart';
import 'package:oluko_app/blocs/movement_weight_bloc.dart';
import 'package:oluko_app/blocs/profile/max_weights_bloc.dart';
import 'package:oluko_app/blocs/segments/current_time_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/request_status_enum.dart';
import 'package:oluko_app/models/max_weight.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/audio_service.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/audio_section.dart';
import 'package:oluko_app/ui/components/coach_request_content.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/people_section.dart';
import 'package:oluko_app/ui/components/segment_step_section.dart';
import 'package:oluko_app/ui/components/vertical_divider.dart' as verticalDivider;
import 'package:oluko_app/ui/newDesignComponents/friends_records_stack.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/ui/newDesignComponents/segment_summary_component.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:oluko_app/utils/timer_utils.dart';
import 'package:oluko_app/utils/user_utils.dart';
import 'package:readmore/readmore.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SegmentImageSection extends StatefulWidget {
  final Function() onPressed;
  final Segment segment;
  final bool showBackButton;
  final int currentSegmentStep;
  final int totalSegmentStep;
  final String userId;
  final Function(List<Audio> audios, Challenge challenge) audioAction;
  final Function(List<UserResponse> users, List<UserSubmodel> favorites) peopleAction;
  final Function(String segmentId) clockAction;
  VoidCallback changeVideoState;
  final CourseEnrollment courseEnrollment;
  final int courseIndex;
  final int classIndex;
  final List<Segment> segments;
  final List<CoachRequest> coachRequests;
  final UserResponse coach;
  final UserResponse currentUser;
  final Challenge challenge;
  final bool fromChallenge;

  SegmentImageSection({
    this.onPressed = null,
    this.segment,
    this.showBackButton = true,
    this.currentSegmentStep,
    this.totalSegmentStep,
    this.challenge,
    this.userId,
    this.audioAction,
    this.clockAction,
    this.peopleAction,
    this.courseEnrollment,
    this.courseIndex,
    this.segments,
    this.classIndex,
    this.coachRequests,
    this.coach,
    this.currentUser,
    this.fromChallenge,
    Key key,
  }) : super(key: key);

  @override
  _SegmentImageSectionState createState() => _SegmentImageSectionState();
}

class _SegmentImageSectionState extends State<SegmentImageSection> {
  GlobalService _globalService = GlobalService();
  ChewieController _controller;
  bool isVideoVisible = false;
  bool _isVideoPlaying = false;
  CoachRequest _coachRequest;
  List<Audio> _challengeAudios;
  int _audioQty;
  bool isFinishedBefore = false;
  List<WeightRecord> weightRecords = [];
  List<EnrollmentMovement> enrollmentMovements = [];
  List<MovementSubmodel> movementsToDisplayWeight = [];
  List<MaxWeight> maxWeightRecords = [];
  List<UserResponse> favoriteUsers = [];
  final String _recordingNotificationSound = 'sounds/recording_notification.wav';

  @override
  void initState() {
    _challengeAudios = widget.challenge == null ? null : AudioService.getNotDeletedAudios(widget.challenge.audios);
    _coachRequest = getSegmentCoachRequest(widget.segment.id);
    BlocProvider.of<DoneChallengeUsersBloc>(context).get(widget.segment.id, widget.userId);
    if (widget.challenge != null) {
      _audioQty = AudioService.getUnseenAudios(widget.challenge.audios);
    }
    getMovementsWithWeightRequired();
    setState(() {
      movementsToDisplayWeight = MovementUtils.getMovementsWithWeights(sections: widget.segment.sections, enrollmentMovements: enrollmentMovements);
    });
    widget.changeVideoState = () {
      if (_controller != null) {
        _controller.pause();
        setState(() {
          _isVideoPlaying = !_isVideoPlaying;
        });
      }
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!widget.fromChallenge) {
          Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.insideClass]));
          return Future(() => false);
        } else {
          return Future(() => true);
        }
      },
      child: imageWithButtons(),
    );
  }

  Widget imageWithButtons() {
    return widget.segment.isChallenge ? challengeSegment() : _defaultSegmentView();
  }

  Widget challengeSegment() {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: ScreenUtils.height(context) / 1.3,
              width: ScreenUtils.width(context),
              child: ListView(
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: OlukoNeumorphism.listViewPhysicsEffect,
                children: [
                  if (widget.segment.isChallenge && !_isVideoPlaying) challengeButtons(isForChallenge: true),
                  _challengeVideoComponent(),
                  _segmentCardComponent(),
                  Container(
                    height: 200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget showVideoPlayer(String videoUrl) {
    return OlukoCustomVideoPlayer(
        videoUrl: videoUrl,
        useConstraints: true,
        roundedBorder: OlukoNeumorphism.isNeumorphismDesign,
        isOlukoControls: true,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => setState(() {
              _controller = chewieController;
            }));
  }

  Widget _challengeVideoComponent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 200,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: showVideoPlayer(widget.segment.videoHLS ?? widget.segment.video),
      ),
    );
  }

  Stack _defaultSegmentView() {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: ScreenUtils.height(context) * 0.6,
              width: ScreenUtils.width(context),
              child: ListView(
                physics: OlukoNeumorphism.listViewPhysicsEffect,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  _segmentCardComponent(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Padding _segmentCardComponent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: segmentContent(),
    );
  }

  Widget _segmentImageSectionChallenge() {
    return Stack(
      children: [
        _segmentCardComponent(),
        if (widget.segment.isChallenge && !_isVideoPlaying) challengeButtons(),
      ],
    );
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

  String _classTitle() => widget.courseEnrollment.classes[widget.classIndex].name;

  Widget segmentContent() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? segmentInformation()
        : Padding(padding: EdgeInsets.only(top: ScreenUtils.height(context) * 0.25, right: 15, left: 15), child: segmentInformation());
  }

  EnrollmentSegment getCourseEnrollmentSegment() {
    final EnrollmentSegment currentEnrollmentSegment =
        widget.courseEnrollment.classes[widget.classIndex].segments.where((enrollmentSegment) => enrollmentSegment.id == widget.segment.id).first;
    return widget
        .courseEnrollment.classes[widget.classIndex].segments[widget.courseEnrollment.classes[widget.classIndex].segments.indexOf(currentEnrollmentSegment)];
  }

  Widget segmentInformation() {
    return BlocBuilder<WorkoutWeightBloc, MovementWorkoutState>(
      builder: (context, state) {
        if (state is WeightRecordsSuccess) {
          weightRecords = state.records;
          movementsToDisplayWeight = MovementUtils.getMovementsWithWeights(sections: widget.segment.sections, enrollmentMovements: enrollmentMovements);
          getMovementsWithWeightRequired();
        }
        if (state is WeightRecordsDispose) {
          weightRecords = state.records;
        }
        return Container(
          width: ScreenUtils.width(context) - 40,
          decoration: BoxDecoration(
            color: OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _segmentSteps(),
                    BlocBuilder<FriendBloc, FriendState>(
                      builder: (context, state) {
                        if (state is GetFriendsSuccess) {
                          favoriteUsers = state.friendUsers;
                          BlocProvider.of<FriendsWeightRecordsBloc>(context).getFriendsWeight(friends: favoriteUsers);
                        }
                        return favoriteUsers != null && favoriteUsers.isNotEmpty
                            ? FriendsRecordsStack(
                                friendsUsers: favoriteUsers,
                                movementsForWeight: movementsToDisplayWeight,
                                segmentStep: _segmentSteps(),
                                segmentTitleWidget: _segmentCardTitle(),
                                useImperial: widget.currentUser.useImperialSystem,
                                currentUserRecords: weightRecords,
                                currentSegmentId: widget.segment.id,
                                userId: widget.currentUser.id)
                            : const SizedBox.shrink();
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                _segmentCardTitle(),
                const SizedBox(height: 10),
                _segmentCardDescription(),
                const SizedBox(height: 10),
                _roundTitle(widget.segment),
                Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: BlocBuilder<MaxWeightsBloc, MaxWeightsState>(
                      builder: (context, state) {
                        if (state is UserMaxWeights) {
                          maxWeightRecords = state.maxWeightRecords;
                        }
                        if (state is UserMaxWeightsDispose) {
                          maxWeightRecords = state.maxWeightRecords;
                        }
                        return SegmentSummaryComponent(
                          segmentId: widget.segment.id,
                          enrollmentMovements: enrollmentMovements,
                          sectionsFromEnrollment: getEnrollmentSections(),
                          sectionsFromSegment: widget.segment.sections,
                          useImperialSystem: widget.currentUser.useImperialSystem,
                          weightRecords: weightRecords ?? [],
                          maxWeightRecords: maxWeightRecords,
                        );
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Text _segmentSteps() {
    return Text(
      "${OlukoLocalizations.get(context, 'segment')} ${widget.currentSegmentStep.toString()}/${widget.totalSegmentStep.toString()}",
      style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w400, customColor: OlukoColors.lightOrange),
    );
  }

  void getMovementsWithWeightRequired() {
    enrollmentMovements = MovementUtils.getMovementsFromEnrollmentSegment(courseEnrollmentSections: getCourseEnrollmentSegment().sections);
  }

  List<EnrollmentSection> getEnrollmentSections() {
    return widget.courseEnrollment.classes[widget.classIndex].segments.firstWhere((segment) => segment.id == widget.segment.id).sections;
  }

  SizedBox _segmentCardTitle() {
    return SizedBox(
      width: ScreenUtils.width(context) - 40,
      child: Text(
        widget.segment.name,
        style: OlukoFonts.olukoSuperBigFont(
          customFontWeight: FontWeight.bold,
          customColor: OlukoColors.white,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  SizedBox _roundTitle(Segment segment) {
    return SizedBox(
      child: Text(
        SegmentUtils.getRoundTitle(segment, context),
        style: OlukoFonts.olukoBigFont(
          customColor: OlukoColors.grayColor,
        ),
        overflow: OlukoNeumorphism.isNeumorphismDesign ? TextOverflow.clip : null,
      ),
    );
  }

  SizedBox _segmentCardDescription() {
    return SizedBox(
      width: OlukoNeumorphism.isNeumorphismDesign ? MediaQuery.of(context).size.width - 40 : null,
      child: ReadMoreText(
        '${widget.segment.description}  ',
        trimLines: 2,
        colorClickableText: OlukoColors.primary,
        trimMode: TrimMode.Line,
        trimCollapsedText: OlukoLocalizations.get(context, 'showMore'),
        trimExpandedText: OlukoLocalizations.get(context, 'showLess'),
        moreStyle: TextStyle(fontSize: 14, color: OlukoColors.primary, fontWeight: FontWeight.bold),
        style: OlukoFonts.olukoMediumFont(
          customColor: OlukoColors.grayColor,
        ),
      ),
    );
  }

  void showCoachDialog() {
    BottomDialogUtils.showBottomDialog(
      context: context,
      content: CoachRequestContent(
        name: widget.coach.firstName,
        image: widget.coach.avatar,
        onNotRecordingAction: navigateToSegmentWithoutRecording,
        onRecordingAction: navigateToSegmentWithRecording,
      ),
    );
  }

  CoachRequest getSegmentCoachRequest(String segmentId) {
    for (var i = 0; i < widget.coachRequests.length; i++) {
      if (widget.coachRequests[i].segmentId == segmentId) {
        return widget.coachRequests[i];
      }
    }
    return null;
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
          'segmentIndex': widget.currentSegmentStep - 1,
          'classIndex': widget.classIndex,
          'coach': widget.coach,
          'courseEnrollment': widget.courseEnrollment,
          'courseIndex': widget.courseIndex,
          'segments': widget.segments,
        },
      );
    }
  }

  navigateToSegmentWithoutRecording() async {
    if ((nextIsLastOne() && widget.segments[widget.currentSegmentStep - 1].rounds == 1) &&
        getSegmentCoachRequest(widget.segments[widget.currentSegmentStep - 1].id) != null) {
      BottomDialogUtils.showBottomDialog(
        backgroundTapEnable: false,
        onDismissAction: () => Navigator.pop(context),
        context: context,
        content: CoachRequestContent(
          name: widget.coach?.firstName ?? '',
          image: widget.coach?.avatar,
          onNotificationDismiss: () {
            Navigator.pop(context);
            TimerUtils.startCountdown(WorkoutType.segment, context, getArguments(), widget.segment.initialTimer);
            BlocProvider.of<CoachRequestStreamBloc>(context).resolve(_coachRequest, widget.courseEnrollment.userId, RequestStatusEnum.ignored);
          },
          isNotification: true,
        ),
      );
      await SoundPlayer().playAsset(asset: _recordingNotificationSound, isForWatch: true);
    } else {
      TimerUtils.startCountdown(WorkoutType.segment, context, getArguments(), widget.segment.initialTimer);
      BlocProvider.of<CoachRequestStreamBloc>(context).resolve(_coachRequest, widget.courseEnrollment.userId, RequestStatusEnum.ignored);
    }
  }

  bool nextIsLastOne() {
    SegmentUtils.getExercisesList(widget.segments[widget.currentSegmentStep - 1]);
    return widget.segments[widget.currentSegmentStep - 1].sections.length ==
        SegmentUtils.getExercisesList(widget.segments[widget.currentSegmentStep - 1]).length - 1;
  }

  Object getArguments() {
    return {
      'segmentIndex': widget.currentSegmentStep - 1,
      'classIndex': widget.classIndex,
      'courseEnrollment': widget.courseEnrollment,
      'courseIndex': widget.courseIndex,
      'workoutType': WorkoutType.segment,
      'coach': widget.coach,
      'segments': widget.segments,
      'fromChallenge': widget.fromChallenge,
      'coachRequest': _coachRequest
    };
  }

  Widget getCameraIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Stack(
        alignment: Alignment.center,
        children: getCameraCircles() +
            [
              Image.asset(
                'assets/courses/outlined_camera.png',
                scale: 3,
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.circle_outlined,
                  size: 16,
                  color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary,
                ),
              )
            ],
      ),
    );
  }

  List<Widget> getCameraCircles() {
    if (_coachRequest != null) {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Image.asset(
            'assets/courses/green_ellipse_1.png',
            scale: 3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Image.asset(
            'assets/courses/green_ellipse_2.png',
            scale: 3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Image.asset(
            'assets/courses/green_ellipse_3.png',
            scale: 3,
          ),
        )
      ];
    } else {
      return [];
    }
  }

  Widget videoWidget() {
    return VisibilityDetector(
      key: Key('videoPlayer'),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction < 0.1 && mounted) {
          closeVideo();
        }
      },
      child: OlukoVideoPreview(
        showCrossButton: false,
        image: widget.segment.image,
        video: VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: widget.segment.videoHLS, videoUrl: widget.segment.video),
        onBackPressed: () => Navigator.pop(context),
        onPlay: () => widget.changeVideoState(),
        videoVisibilty: _isVideoPlaying,
      ),
    );
  }

  void closeVideo() {
    if (_isVideoPlaying) {
      setState(() {
        _isVideoPlaying = !_isVideoPlaying;
      });
    }
  }

  Widget challengeButtons({bool isForChallenge = false}) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Padding(
            padding: isForChallenge ? EdgeInsets.fromLTRB(20, 20, 20, 20) : EdgeInsets.only(left: 20, top: ScreenUtils.height(context) * 0.20),
            child: challengeButtonsContent(),
          )
        : Padding(
            padding: EdgeInsets.only(left: 20, top: ScreenUtils.height(context) * 0.13),
            child: challengeButtonsContent(),
          );
  }

  Container challengeButtonsContent() {
    const verticalDividerComponent = verticalDivider.VerticalDivider(
      width: 30,
      height: OlukoNeumorphism.isNeumorphismDesign ? 80 : 60,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getAudioButton(),
                verticalDividerComponent,
                BlocBuilder<DoneChallengeUsersBloc, DoneChallengeUsersState>(
                  builder: (context, doneChallengeUsersState) {
                    if (doneChallengeUsersState is DoneChallengeUsersSuccess) {
                      final int favorites = doneChallengeUsersState.favoriteUsers != null ? doneChallengeUsersState.favoriteUsers.length : 0;
                      final int normalUsers = doneChallengeUsersState.users != null ? doneChallengeUsersState.users.length : 0;
                      final int qty = favorites + normalUsers;
                      return PeopleAndIncludedInButtons(
                        widget: widget,
                        qty: qty,
                        state: doneChallengeUsersState,
                      );
                    } else {
                      return PeopleAndIncludedInButtons(widget: widget);
                    }
                  },
                ),
                if (OlukoNeumorphism.isNeumorphismDesign) verticalDividerComponent,
                GestureDetector(onTap: () => widget.clockAction(widget.segments[widget.currentSegmentStep - 1].id), child: clockSection()),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getAudioButton() {
    return BlocBuilder<ChallengeAudioBloc, ChallengeAudioState>(
      builder: (context, state) {
        if (state is MarkAsSeenChallengeAudioSuccess) {
          _audioQty = 0;
        }
        return GestureDetector(
          onTap: () {
            widget.audioAction(_challengeAudios, widget.challenge);
            BlocProvider.of<ChallengeAudioBloc>(context).markAsSeen(_challengeAudios, widget.challenge.id);
          },
          child: AudioSection(audioMessageQty: _audioQty),
        );
      },
    );
  }

  Widget clockSection() {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Image.asset(
              'assets/courses/clock.png',
              height: 24,
              width: 27,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            OlukoLocalizations.get(context, 'personalRecord'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
          )
        ],
      ),
    );
  }

  _onStartPressed() {
    widget.changeVideoState();
    //CoachRequest coachRequest = getSegmentCoachRequest(widget.segment.id);
    if (_coachRequest != null) {
      showCoachDialog();
    } else {
      navigateToSegmentWithoutRecording();
    }
  }
}

class PeopleAndIncludedInButtons extends StatelessWidget {
  const PeopleAndIncludedInButtons({
    Key key,
    @required this.widget,
    this.state,
    this.qty,
  }) : super(key: key);

  final SegmentImageSection widget;
  final DoneChallengeUsersSuccess state;
  final int qty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (state != null)
          GestureDetector(
            onTap: () => widget.peopleAction(state.userResponseList, state.favoriteUsers),
            child: PeopleSection(peopleQty: qty, isChallenge: widget.segment.isChallenge),
          )
        else
          PeopleSection(peopleQty: 0, isChallenge: widget.segment.isChallenge),
      ],
    );
  }
}
