import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/coach/coach_interaction_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_timeline_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_content_for_timeline_panel.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/coach_timeline_circle_content.dart';
import 'package:oluko_app/ui/components/coach_timeline_video_content.dart';
import 'package:oluko_app/ui/components/tab_content_list.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/user_utils.dart';
import 'coach_timeline_card_content.dart';
import 'oluko_circular_progress_indicator.dart';
import "package:collection/collection.dart";

class CoachTimelinePanel extends StatefulWidget {
  final bool isIntroductionVideoComplete;
  final UserResponse currentUser;
  final Function onCurrentUserSelected;
  const CoachTimelinePanel({this.isIntroductionVideoComplete, this.currentUser, this.onCurrentUserSelected});
  @override
  _CoachTimelinePanelConteState createState() => _CoachTimelinePanelConteState();
}

class _CoachTimelinePanelConteState extends State<CoachTimelinePanel> with TickerProviderStateMixin {
  TabController _tabController;
  List<Widget> contentList = [];
  List<List<Widget>> contentWithListNodes = [];
  List<CoachTimelineGroup> _timelineContentItems;
  List<CoachTimelineItem> timelineItems = [];
  List<UserResponse> _friendUsersList = [];
  int _actualTabIndex = 0;
  bool _isForFriend = false;
  final bool _showTimelineFriends = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _timelineHeaderSafeSpace = Container(
    height: 50,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachTimelineBloc, CoachTimelineState>(
      builder: (context, state) {
        if (state is CoachTimelineTabsUpdate) {
          _tabController = TabController(length: state.timelineContentItems.length, vsync: this);
          _timelineContentItems = state.timelineContentItems;
          _isForFriend = state.isForFriend;
        }
        return BlocBuilder<FriendBloc, FriendState>(
          builder: (context, friendState) {
            if (friendState is GetFriendsSuccess) {
              _friendUsersList = friendState.friendUsers.where((friendUser) => _canShowFriendContent(friendUser)).toList();
              if (_friendUsersList.where((user) => user.id == widget.currentUser.id).toList().isEmpty) {
                _friendUsersList.insert(0, widget.currentUser);
              }
            }
            return Column(
              children: [
                _timelineHeaderSafeSpace,
                if (_friendUsersList.isNotEmpty && _showTimelineFriends) _timelineFriendsListSection(context) else const SizedBox.shrink(),
                _timelineTabsSection(context),
                _timelineListContentSection(),
                Container(
                  height: 50,
                )
              ],
            );
          },
        );
      },
    );
  }

  Padding _timelineFriendsListSection(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(2, 5, 2, 5),
        child: Container(
            height: 80,
            child: _friendUsersList.isNotEmpty
                ? ListView(
                    physics: OlukoNeumorphism.listViewPhysicsEffect,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    children: _friendUsersList
                        .map(
                          (friend) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: GestureDetector(
                              onTap: () async {
                                if (friend.id == widget.currentUser.id) {
                                  widget.onCurrentUserSelected();
                                } else {
                                  _getTimelineActivityForFriend(context, friend);
                                }
                              },
                              child: _createFriendTimelineProfileElement(friend, context),
                            ),
                          ),
                        )
                        .toList())
                : const SizedBox.shrink()));
  }

  Container _timelineTabsSection(BuildContext context) {
    return Container(
      child: TabBar(
          labelColor: OlukoColors.black,
          indicatorColor: OlukoColors.primary,
          indicatorWeight: 4,
          isScrollable: true,
          controller: _tabController,
          onTap: (index) {
            _actualTabIndex = index;
          },
          tabs: _timelineContentItems
              .map((content) => Tab(
                    child: _timelineContentItems.length < 5
                        ? Container(
                            width: _timelineContentItems.length == 1
                                ? MediaQuery.of(context).size.width
                                : (MediaQuery.of(context).size.width / _splitMiddleOrDivideEach()),
                            child: _tabTitleContent(content),
                          )
                        : Container(
                            child: _tabTitleContent(content),
                          ),
                  ))
              .toList()),
    );
  }

  int _splitMiddleOrDivideEach() => _timelineContentItems.length < 3 ? 2 : (_timelineContentItems.length - 1);

  Text _tabTitleContent(CoachTimelineGroup content) {
    return Text(content.courseName,
        textAlign: TextAlign.center, style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700));
  }

  Expanded _timelineListContentSection() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: passContentToWidgets()
            .map((widgetCollection) => Container(
                  color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TabContentList(contentToDisplay: widgetCollection),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Column _createFriendTimelineProfileElement(UserResponse friend, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            width: 60,
            height: 55,
            child: Neumorphic(
                style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                child: friend.avatar != null || friend.avatarThumbnail != null
                    ? CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(friend.avatar ?? friend.avatarThumbnail),
                        radius: 40.0,
                        child: const SizedBox.shrink(),
                      )
                    : UserUtils.avatarImageDefault(maxRadius: 40, name: friend.firstName, lastname: friend.lastName)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            height: 10,
            child: Text(
              _isCurrentUser(friend) ? OlukoLocalizations.of(context).find('me') : friend.username,
              overflow: TextOverflow.ellipsis,
              style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }

  bool _canShowFriendContent(UserResponse friendUser) =>
      friendUser.currentPlan >= 1 && PrivacyOptions.getPrivacyValue(friendUser.privacy) == SettingsPrivacyOptions.public;

  bool _isCurrentUser(UserResponse friend) => friend.id == widget.currentUser.id;

  Future<void> _getTimelineActivityForFriend(BuildContext context, UserResponse friend) async {
    List<CoachTimelineGroup> _timelinePanelContent = [];
    List<CoachTimelineItem> _allContent = [];
    List<CoachTimelineItem> items = await BlocProvider.of<CoachTimelineItemsBloc>(context).getTimelineItemsForUser(friend.id);
    _timelinePanelContent = CoachTimelineFunctions.getTimelineContentForPanel(context,
        timelineContentTabs: _timelinePanelContent,
        timelineItemsFromState: items,
        allContent: _allContent,
        listOfCoursesId: items.map((e) => e.course != null ? e.course.id : '0').toList(),
        isForFriend: true);
    BlocProvider.of<CoachTimelineBloc>(context).emitTimelineTabsUpdate(contentForTimelinePanel: _timelinePanelContent, isForFriend: true);
  }

  List<List<Widget>> passContentToWidgets() {
    List<List<Widget>> finalListOfWidgetContent = [];
    _timelineContentItems.forEach((CoachTimelineGroup timelineTabContent) {
      List<Widget> listOfWidgets = [];
      Map<String, List<CoachTimelineItem>> tabDateAndContentList =
          groupBy(timelineTabContent.timelineElements, (CoachTimelineItem obj) => DateFormat.yMMMd().format(obj.createdAt.toDate()));

      List<MapEntry<String, List<CoachTimelineItem>>> entries = tabDateAndContentList.entries.toList();
      entries.forEach((entry) {
        String date = entry.key;
        final List<CoachTimelineItem> items = entry.value;

        listOfWidgets.add(widgetToUse(date, items));
      });
      finalListOfWidgetContent.insert(_timelineContentItems.indexOf(timelineTabContent), listOfWidgets);
    });
    return finalListOfWidgetContent;
  }

  StatelessWidget switchTypeWidget(CoachTimelineItem content) {
    switch (content.contentType) {
      case TimelineInteractionType.course:
        return GestureDetector(
          onTap: _isForFriend
              ? () {}
              : () {
                  if (!widget.isIntroductionVideoComplete) {
                    BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
                  }
                  Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                      arguments: {'course': content.courseForNavigation, 'fromCoach': true, 'isCoachRecommendation': false});
                },
          child: Container(
            color: OlukoNeumorphismColors.appBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachTimelineCardContent(
                  cardImage: content.contentThumbnail,
                  cardTitle: content.contentName,
                  cardSubTitle: content.courseForNavigation != null ? content.courseForNavigation.duration : '',
                  date: content.createdAt.toDate(),
                  fileType: CoachFileTypeEnum.recommendedCourse,
                ),
              ],
            ),
          ),
        );
      case TimelineInteractionType.classes:
        return Container(
          color: OlukoNeumorphismColors.appBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoachTimelineCardContent(
                cardImage: content.contentThumbnail,
                cardTitle: content.contentName,
                cardSubTitle: content.course.name,
                date: content.createdAt.toDate(),
                fileType: CoachFileTypeEnum.recommendedClass,
              ),
            ],
          ),
        );
      case TimelineInteractionType.segment:
        return GestureDetector(
          onTap: _isForFriend
              ? () {}
              : () {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                    'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(
                        videoHlsUrl: content.sentVideosForNavigation.first.videoHls, videoUrl: content.sentVideosForNavigation.first.video?.url),
                    'titleForContent': OlukoLocalizations.of(context).find('sentVideo')
                  });
                },
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachTimelineVideoContent(
                    videoThumbnail: content.contentThumbnail,
                    videoTitle: content.contentDescription ?? OlukoLocalizations.get(context, 'sentVideo'),
                    date: content.createdAt.toDate(),
                    fileType: CoachFileTypeEnum.sentVideo),
              ],
            ),
          ),
        );
      case TimelineInteractionType.movement:
        return GestureDetector(
          onTap: _isForFriend
              ? () {}
              : () {
                  if (!widget.isIntroductionVideoComplete) {
                    BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
                  }
                  Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': content.movementForNavigation});
                },
          child: Container(
            color: OlukoNeumorphismColors.appBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachTimelineCircleContent(
                    circleImage: content.contentThumbnail,
                    circleTitle: content.contentName,
                    date: content.createdAt.toDate(),
                    fileType: CoachFileTypeEnum.recommendedMovement),
              ],
            ),
          ),
        );
      case TimelineInteractionType.mentoredVideo:
        return GestureDetector(
          onTap: _isForFriend
              ? () {}
              : () {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                    'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(
                        videoHlsUrl: content.mentoredVideosForNavigation.first.videoHLS, videoUrl: content.mentoredVideosForNavigation.first.video.url),
                    'titleForContent': OlukoLocalizations.of(context).find('personalizedVideo')
                  });
                },
          child: Container(
            color: OlukoNeumorphismColors.appBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachTimelineVideoContent(
                    videoThumbnail: content.contentThumbnail,
                    videoTitle: content.contentDescription ?? OlukoLocalizations.get(context, 'personalizedVideo'),
                    date: content.createdAt.toDate(),
                    fileType: CoachFileTypeEnum.mentoredVideo),
              ],
            ),
          ),
        );
      case TimelineInteractionType.sentVideo:
        return GestureDetector(
          onTap: _isForFriend
              ? () {}
              : () {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                    'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(
                        videoHlsUrl: content.sentVideosForNavigation.first.videoHls, videoUrl: content.sentVideosForNavigation.first.video?.url),
                    'titleForContent': OlukoLocalizations.of(context).find('sentVideo')
                  });
                },
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachTimelineVideoContent(
                    videoThumbnail: content.contentThumbnail,
                    videoTitle: content.contentDescription ?? OlukoLocalizations.get(context, 'sentVideo'),
                    date: content.createdAt.toDate(),
                    fileType: CoachFileTypeEnum.sentVideo),
              ],
            ),
          ),
        );
      case TimelineInteractionType.recommendedVideo:
        return GestureDetector(
          onTap: _isForFriend
              ? () {}
              : () {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                    'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(
                        videoHlsUrl: content.recommendationMedia.videoHls, videoUrl: content.recommendationMedia.video.url),
                    'titleForContent': OlukoLocalizations.of(context).find('recommendedVideos')
                  });
                },
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachTimelineVideoContent(
                    videoThumbnail: content.contentThumbnail,
                    videoTitle: content.contentName ?? OlukoLocalizations.get(context, 'recommendedVideos'),
                    date: content.createdAt.toDate(),
                    fileType: CoachFileTypeEnum.recommendedVideo),
              ],
            ),
          ),
        );
      case TimelineInteractionType.messageVideo:
        return GestureDetector(
          onTap: _isForFriend
              ? () {}
              : () {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                    'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(
                        videoHlsUrl: content.coachMediaMessage.videoHls, videoUrl: content.coachMediaMessage.video.url),
                    'titleForContent': OlukoLocalizations.of(context).find('coachMessageVideo')
                  });
                },
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachTimelineVideoContent(
                    videoThumbnail: content.contentThumbnail,
                    videoTitle: content.contentName ?? OlukoLocalizations.get(context, 'coachMessageVideo'),
                    date: content.createdAt.toDate(),
                    fileType: CoachFileTypeEnum.messageVideo),
              ],
            ),
          ),
        );
      case TimelineInteractionType.introductionVideo:
        return GestureDetector(
          onTap: _isForFriend
              ? () {}
              : () {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                    'videoUrl': content.mentoredVideosForNavigation.first.videoHLS ?? content.mentoredVideosForNavigation.first.video?.url,
                    'titleForContent': OlukoLocalizations.of(context).find('introductionVideo')
                  });
                },
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachTimelineVideoContent(
                    videoThumbnail: content.contentThumbnail,
                    videoTitle: content.contentName ?? OlukoLocalizations.get(context, 'introductionVideo'),
                    date: content.createdAt.toDate(),
                    fileType: CoachFileTypeEnum.introductionVideo),
              ],
            ),
          ),
        );
      case TimelineInteractionType.welcomeVideo:
        return GestureDetector(
          onTap: _isForFriend
              ? () {}
              : () {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo],
                      arguments: {'videoUrl': content.mentoredVideosForNavigation, 'titleForContent': OlukoLocalizations.of(context).find('welcomeVideo')});
                },
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachTimelineVideoContent(
                    videoThumbnail: content.contentThumbnail,
                    videoTitle: content.contentName ?? OlukoLocalizations.get(context, 'welcomeVideo'),
                    date: content.createdAt.toDate(),
                    fileType: CoachFileTypeEnum.welcomeVideo),
              ],
            ),
          ),
        );
      default:
        return Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator());
    }
  }

  Widget widgetToUse(String date, List<CoachTimelineItem> contentList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(date == DateFormat.yMMMd().format(DateTime.now()) ? OlukoLocalizations.get(context, 'today') : date,
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500)),
        ),
        Column(children: contentList.map((content) => switchTypeWidget(content)).toList()),
      ],
    );
  }
}
