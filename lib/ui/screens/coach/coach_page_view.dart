import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_messages_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_review_pending_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_video_message_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_helper_functions.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/coach_app_bar.dart';
import 'package:oluko_app/ui/components/coach_sliding_up_panel.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_carousel_content.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_horizontal_carousel.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachPageView extends StatefulWidget {
  UserResponse currentAuthUser;
  CoachUser coachUser;
  List<CoachTimelineGroup> coachTimelineContent;
  List<CoachRecommendationDefault> coachRecommendationList;
  CoachPageView({Key key, this.currentAuthUser, this.coachUser, this.coachTimelineContent, this.coachRecommendationList}) : super(key: key);

  @override
  State<CoachPageView> createState() => _CoachPageViewState();
}

String _welcomeVideoUrl = '';
num numberOfReviewPendingItems = 0;
List<Annotation> _annotationVideosList = [];
List<SegmentSubmission> _sentVideosList = [];
List<SegmentSubmission> segmentsWithReview = [];
List<CoachMediaMessage> _coachVideoMessageList = [];

class _CoachPageViewState extends State<CoachPageView> {
  @override
  Widget build(BuildContext context) {
    return CoachSlidingUpPanel(
      content: Scaffold(
        appBar: _getCoachAppBar(context),
        body: CoachSlidingUpPanel(
          content: coachTabBodyComponent(),
          timelineItemsContent: widget.coachTimelineContent,
          isIntroductionVideoComplete: true,
          currentUser: widget.currentAuthUser,
          onCurrentUserSelected: () => BlocProvider.of<CoachTimelineBloc>(context).emitTimelineTabsUpdate(contentForTimelinePanel: widget.coachTimelineContent),
        ),
      ),
    );
  }

  Widget coachTabBodyComponent() {
    return BlocBuilder<CoachMentoredVideosBloc, CoachMentoredVideosState>(
      builder: (context, annotationsState) {
        if (annotationsState is CoachMentoredVideosSuccess) {
          _annotationVideosList = annotationsState.mentoredVideos.where((mentoredVideo) => mentoredVideo.video != null).toList();
          // _addCoachAssignmentVideo();
        }
        if (annotationsState is CoachMentoredVideosUpdate) {
          _annotationVideosList = CoachHelperFunctions.checkAnnotationUpdate(annotationsState.mentoredVideos, _annotationVideosList);
        }
        return BlocBuilder<CoachSentVideosBloc, CoachSentVideosState>(
          builder: (context, sentVideosState) {
            if (sentVideosState is CoachSentVideosSuccess) {
              _sentVideosList = sentVideosState.sentVideos.where((sentVideo) => sentVideo.video != null && sentVideo.coachId == widget.coachUser.id).toList();
              _pendingReviewProcess();
              _updateReviewPendingOnCoachAppBar(context);
            }
            return BlocBuilder<CoachVideoMessageBloc, CoachVideoMessageState>(
              builder: (context, coachVideoMessageState) {
                if (coachVideoMessageState is CoachVideoMessageSuccess) {
                  _coachVideoMessageList = coachVideoMessageState.coachVideoMessages;
                }
                return BlocBuilder<IntroductionMediaBloc, IntroductionMediaState>(
                  builder: (context, introductionMediaState) {
                    if (introductionMediaState is Success) {
                      _welcomeVideoUrl = introductionMediaState.mediaURL;
                    }
                    return BlocListener<CoachAudioMessageBloc, CoachAudioMessagesState>(
                      listener: (context, coachAudioMessageState) {
                        if (coachAudioMessageState is CoachAudioMessagesSent) {
                          AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'audioMessageSent'));
                        } else if (coachAudioMessageState is CoachAudioMessagesFailure) {
                          AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'audioMessageFailed'));
                        }
                      },
                      child: Container(
                        color: OlukoNeumorphismColors.appBackgroundColor,
                        child: Theme(
                          data: Theme.of(context).copyWith(colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.transparent)),
                          child: ListView.builder(
                            physics: OlukoNeumorphism.listViewPhysicsEffect,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: false,
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  _reviewsPendingSection(),
                                  // _notificationPanelSection(carouselNotificationWidgetList, coachCarouselSliderSection),
                                  _getMentoredVideosSection(),
                                  _getSentVideosSection(),
                                  _getMessageVideosSection(),
                                  _getRecommendedVideosSection(),
                                  _getRecommendedMovementsSection(), // _getRecommendedCourses(context),
                                  // _defaultBottomSafeSpace()
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _getMentoredVideosSection() => CoachHelperFunctions.getMentoredVideos(context, _annotationVideosList, widget.currentAuthUser);

  Widget _getMessageVideosSection() => CoachHelperFunctions.getMessageVideos(context, _coachVideoMessageList);

  Widget _getRecommendedVideosSection() => CoachHelperFunctions.getRecommendedVideos(context, widget.coachRecommendationList);

  Widget _getRecommendedMovementsSection() => CoachHelperFunctions.getRecommendedMovements(context, widget.coachRecommendationList);

  Widget _getSentVideosSection() => CoachHelperFunctions.getSendVideos(
        context,
        _sentVideosList,
      );

  CoachAppBar _getCoachAppBar(BuildContext context) => CoachAppBar(coachUser: widget.coachUser, currentUser: widget.currentAuthUser, onNavigationAction: () {}
      // onNavigationAction: () =>
      // !coachAssignment.introductionCompleted ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation() : () {},
      );

  Widget _reviewsPendingSection() {
    return BlocConsumer<CoachReviewPendingBloc, CoachReviewPendingState>(
      listener: (context, state) {
        if (state is CoachReviewPendingDispose) {
          numberOfReviewPendingItems = state.reviewsPendingDisposeValue;
        }
        if (state is CoachReviewPendingSuccess) {
          numberOfReviewPendingItems = state.reviewsPending;
        }
      },
      builder: (context, state) {
        return numberOfReviewPendingItems != 0
            ? Container(
                width: ScreenUtils.width(context),
                height: 50,
                color: OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$numberOfReviewPendingItems ${OlukoLocalizations.get(context, 'reviewsPending')}',
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor.withOpacity(0.5), customFontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  void _pendingReviewProcess() => _sentVideosList.forEach((sentVideo) {
        segmentsWithReview = CoachHelperFunctions.checkPendingReviewsForSentVideos(
            sentVideo: sentVideo, annotationVideosContent: _annotationVideosList, segmentsWithReview: segmentsWithReview);
      });
  void _updateReviewPendingOnCoachAppBar(BuildContext context) => BlocProvider.of<CoachReviewPendingBloc>(context).updateReviewPendingMessage(
        _sentVideosList != null && segmentsWithReview != null ? _sentVideosList.length - segmentsWithReview.length : 0,
      );
  //  void _addCoachAssignmentVideo() => _annotationVideosList = CoachHelperFunctions.addIntroVideoOnAnnotations(_annotationVideosList, _introductionVideo);
}
