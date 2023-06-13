import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/audio_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/panel_audio_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/done_challenge_users_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/segment_detail_content_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/challenge_audio_section.dart';
import 'package:oluko_app/ui/components/delete_audio_panel.dart';
import 'package:oluko_app/ui/components/modal_people_enrolled.dart';
import 'package:oluko_app/ui/components/modal_personal_record.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/segment_image_section.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_text_button.dart';
import 'package:oluko_app/ui/screens/courses/challenge_detail_section.dart';
import 'package:oluko_app/ui/screens/courses/course_info_section.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum PanelEnum { audios, classDetail }

class UserChallengeDetail extends StatefulWidget {
  final Challenge challenge;
  final UserResponse userRequested;

  UserChallengeDetail({this.challenge, this.userRequested, Key key}) : super(key: key);

  @override
  _UserChallengeDetailState createState() => _UserChallengeDetailState();
}

class FirebaseUser {}

class _UserChallengeDetailState extends State<UserChallengeDetail> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  Class _class;
  Segment _segment;
  CourseEnrollment _courseEnrollment;
  PanelController panelController = PanelController();
  final PanelController _challengePanelController = PanelController();
  UserResponse _user;
  List<UserResponse> _audioUsers;

  Widget panelContent;
  PanelEnum panelState;

  //audio
  final SoundRecorder recorder = SoundRecorder();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<PanelAudioBloc>(context).deleteAudio(false, false);
    recorder.init();
    BlocProvider.of<DoneChallengeUsersBloc>(context).get(widget.challenge.segmentId, widget.userRequested.id);
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.user;
        BlocProvider.of<ClassBloc>(context).get(widget.challenge.classId);
        BlocProvider.of<CourseEnrollmentBloc>(context).getById(widget.challenge.courseEnrollmentId);
        BlocProvider.of<SegmentBloc>(context).getById(widget.challenge.segmentId);
        return BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
          return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(builder: (context, enrollmentState) {
            return BlocBuilder<SegmentBloc, SegmentState>(builder: (context, segmentState) {
              if (classState is GetByIdSuccess && enrollmentState is GetEnrollmentByIdSuccess && segmentState is GetSegmentSuccess) {
                _class = classState.classObj;
                _courseEnrollment = enrollmentState.courseEnrollment;
                _segment = segmentState.segment;

                return form();
              } else {
                return SizedBox();
              }
            });
          });
        });
      } else {
        return SizedBox();
      }
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                maxHeight: 250,
                minHeight: 5,
                collapsed: Container(
                  color: OlukoNeumorphismColors.appBackgroundColor,
                ),
                panel: DeleteAudioPanel(panelController: panelController),
                body: Container(
                  color: OlukoNeumorphismColors.appBackgroundColor,
                  child: classInfoSection(),
                )),
            slidingUpPanelComponent(context),
          ],
        )));
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
          if (state is SegmentDetailContentPeopleOpen) {
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
          }
          if (state is SegmentDetailContentClockOpen) {
            _challengePanelController.open();
            _contentForPanel = ModalPersonalRecord(segmentId: widget.challenge.segmentId, userId: widget.userRequested.id);
          }
          if (state is SegmentDetailContentLoading) {
            _contentForPanel = UploadingModalLoader(UploadFrom.segmentDetail);
          }
          return _contentForPanel;
        }),
      ),
    );
  }

  Widget showVideoPlayer(String videoUrl) {
    return OlukoCustomVideoPlayer(
        videoUrl: videoUrl,
        useConstraints: true,
        roundedBorder: OlukoNeumorphism.isNeumorphismDesign,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => setState(() {
              _controller = chewieController;
            }));
  }

  Widget classInfoSection() {
    return Stack(children: [
      ListView(addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Column(children: [
              OverlayVideoPreview(image: _segment.image, video: _segment.challengeVideo, showBackButton: true, bottomWidgets: [
                BlocBuilder<DoneChallengeUsersBloc, DoneChallengeUsersState>(builder: (context, doneChallengeUsersState) {
                  if (doneChallengeUsersState is DoneChallengeUsersSuccess) {
                    final int favorites = doneChallengeUsersState.favoriteUsers != null ? doneChallengeUsersState.favoriteUsers.length : 0;
                    final int normalUsers = doneChallengeUsersState.users != null ? doneChallengeUsersState.users.length : 0;
                    final int qty = favorites + normalUsers;
                    return CourseInfoSection(
                      isUserChallengeSection: true,
                      peopleQty: qty,
                      image: _courseEnrollment.course.image,
                      clockAction: () => _clockAction(widget.challenge.segmentId),
                      onPeoplePressed: () => _peopleAction(
                        doneChallengeUsersState.users,
                        doneChallengeUsersState.favoriteUsers,
                      ),
                    );
                  } else {
                    return CourseInfoSection(
                      peopleQty: 0,
                      image: _courseEnrollment.course.image,
                      clockAction: () {},
                    );
                  }
                })
              ]),
              ChallengeDetailSection(segment: _segment),
              Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                height: ScreenUtils.height(context) * 0.16,
              )
            ])),
      ]),
      Positioned(bottom: 0, child: showChallengeAudioModal())
    ]);
  }

  _peopleAction(List<UserSubmodel> users, List<UserSubmodel> favorites) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openPeoplePanel(users, favorites);
  }

  _clockAction(String segmentId) {
    BlocProvider.of<SegmentDetailContentBloc>(context).openClockPanel(segmentId);
  }

  Widget showChallengeAudioModal() {
    return SizedBox(
      width: ScreenUtils.width(context),
      child: ChallengeAudioSection(
        user: _user,
        challengeId: widget.challenge.id,
        recorder: recorder,
        userFirstName: widget.userRequested.firstName,
        panelController: panelController,
      ),
    );
  }
}
