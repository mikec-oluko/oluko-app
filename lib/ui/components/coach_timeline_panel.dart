import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_timeline_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/coach_timeline_circle_content.dart';
import 'package:oluko_app/ui/components/coach_timeline_video_content.dart';
import 'package:oluko_app/ui/components/tab_content_list.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'coach_timeline_card_content.dart';
import 'oluko_circular_progress_indicator.dart';
import "package:collection/collection.dart";

class CoachTimelinePanel extends StatefulWidget {
  final bool isIntroductionVideoComplete;
  const CoachTimelinePanel({this.isIntroductionVideoComplete});
  @override
  _CoachTimelinePanelConteState createState() => _CoachTimelinePanelConteState();
}

class _CoachTimelinePanelConteState extends State<CoachTimelinePanel> with TickerProviderStateMixin {
  TabController _tabController;
  List<Widget> contentList = [];
  List<List<Widget>> contentWithListNodes = [];
  List<CoachTimelineGroup> _timelineContentItems;
  List<CoachTimelineItem> timelineItems = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachTimelineBloc, CoachTimelineState>(
      builder: (context, state) {
        if (state is CoachTimelineTabsUpdate) {
          _tabController = TabController(length: state.timelineContentItems.length, vsync: this);
          _timelineContentItems = state.timelineContentItems;
        }
        return Scaffold(
            appBar: AppBar(
              backgroundColor: OlukoNeumorphismColors.appBackgroundColor,
              flexibleSpace: Container(
                decoration: UserInformationBackground.getContainerGradientDecoration(
                    customBorder: false, isNeumorphic: OlukoNeumorphism.isNeumorphismDesign),
              ),
              automaticallyImplyLeading: false,
              bottom: TabBar(
                  labelColor: OlukoColors.black,
                  indicatorColor: OlukoColors.coachTabIndicatorColor,
                  isScrollable: true,
                  controller: _tabController,
                  tabs: _timelineContentItems
                      .map((content) => Tab(
                            child: Container(
                              width: MediaQuery.of(context).size.width / _timelineContentItems.length,
                              child: Text(content.courseName.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)),
                            ),
                          ))
                      .toList()),
            ),
            body: _timelineContentItems == null
                ? Container(color: OlukoNeumorphismColors.appBackgroundColor, child: OlukoCircularProgressIndicator())
                : _timelineContentItems.isNotEmpty
                    ? TabBarView(
                        controller: _tabController,
                        children: passContentToWidgets()
                            .map((widgetCollection) => Container(
                                  color: OlukoNeumorphism.isNeumorphismDesign
                                      ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark
                                      : OlukoColors.black,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TabContentList(contentToDisplay: widgetCollection),
                                  ),
                                ))
                            .toList(),
                      )
                    : Container(
                        color: OlukoNeumorphismColors.appBackgroundColor,
                        child: Center(
                          child: Text(
                            OlukoLocalizations.get(context, 'noContent'),
                            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500),
                          ),
                        ),
                      ));
      },
    );
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
        List<CoachTimelineItem> items = entry.value;

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
          onTap: () {
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
                  cardSubTitle: content.courseForNavigation?.duration,
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
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoachTimelineVideoContent(
                  videoThumbnail: content.contentThumbnail,
                  videoTitle: content.contentName ?? OlukoLocalizations.get(context, 'sentVideo'),
                  date: content.createdAt.toDate(),
                  fileType: CoachFileTypeEnum.sentVideo),
            ],
          ),
        );
      case TimelineInteractionType.movement:
        return GestureDetector(
          onTap: () {
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
        return Container(
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
        );
      case TimelineInteractionType.sentVideo:
        return Container(
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
        );
      case TimelineInteractionType.recommendedVideo:
        return Container(
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
        );
      case TimelineInteractionType.messageVideo:
        return Container(
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
        );
      case TimelineInteractionType.introductionVideo:
        return Container(
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
        );
      case TimelineInteractionType.welcomeVideo:
        return Container(
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
        );
      //   break;
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
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)),
        ),
        Column(children: contentList.map((content) => switchTypeWidget(content)).toList()),
      ],
    );
  }
}
