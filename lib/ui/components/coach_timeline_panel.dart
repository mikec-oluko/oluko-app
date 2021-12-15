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
              backgroundColor: OlukoColors.black,
              flexibleSpace: Container(
                decoration: UserInformationBackground.getContainerGradientDecoration(
                    customBorder: true, isNeumorphic: OlukoNeumorphism.isNeumorphismDesign),
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
                                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                            ),
                          ))
                      .toList()),
            ),
            body: _timelineContentItems == null
                ? Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator())
                : _timelineContentItems.isNotEmpty
                    ? TabBarView(
                        controller: _tabController,
                        children: passContentToWidgets()
                            .map((e) => Container(
                                  color: OlukoColors.black,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TabContentList(contentToDisplay: e),
                                  ),
                                ))
                            .toList(),
                      )
                    : Container(
                        color: OlukoColors.black,
                        child: Center(
                          child: Text(
                            OlukoLocalizations.get(context, 'noContent'),
                            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                          ),
                        ),
                      ));
      },
    );
  }

  List<List<Widget>> passContentToWidgets() {
    Widget widgetTypeToUse;
    List<Widget> listOfWidgets = [];
    List<List<Widget>> finalListOfWidgetContent = [];
    _timelineContentItems.forEach((content) {
      content.timelineElements.forEach((element) {
        widgetTypeToUse = getWidgedToUse(element);
        listOfWidgets.add(widgetTypeToUse);
      });
      finalListOfWidgetContent.insert(_timelineContentItems.indexOf(content), listOfWidgets);
      listOfWidgets = [];
    });
    return finalListOfWidgetContent;
  }

  Widget getWidgedToUse(CoachTimelineItem content) {
    DateTime now = DateTime.now();

    final dateForContent = Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Text(
          !now.isAfter(content.createdAt.toDate())
              ? OlukoLocalizations.get(context, 'today')
              : DateFormat.yMMMd().format(content.createdAt.toDate()),
          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
    );

    switch (TimelineContentOption.getTimelineOption(content.contentType as int)) {
      case TimelineInteractionType.course:
        return GestureDetector(
          onTap: () {
            if (!widget.isIntroductionVideoComplete) {
              BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
            }
            Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                arguments: {'course': content.courseForNavigation, 'fromCoach': true});
          },
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dateForContent,
                CoachTimelineCardContent(
                  cardImage: content.contentThumbnail,
                  cardTitle: content.contentName,
                  cardSubTitle: content.contentDescription,
                  date: content.createdAt.toDate(),
                  fileType: CoachFileTypeEnum.recommendedCourse,
                ),
              ],
            ),
          ),
        );
      case TimelineInteractionType.classes:
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateForContent,
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
              dateForContent,
              CoachTimelineCircleContent(
                  circleImage: content.contentThumbnail,
                  circleTitle: content.contentName,
                  date: content.createdAt.toDate(),
                  fileType: CoachFileTypeEnum.recommendedSegment),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dateForContent,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateForContent,
              CoachTimelineVideoContent(
                  videoThumbnail: content.contentThumbnail,
                  videoTitle: content.contentName ?? OlukoLocalizations.get(context, 'mentoredVideo'),
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
              dateForContent,
              CoachTimelineVideoContent(
                  videoThumbnail: content.contentThumbnail,
                  videoTitle: content.contentName ?? OlukoLocalizations.get(context, 'sentVideo'),
                  date: content.createdAt.toDate(),
                  fileType: CoachFileTypeEnum.sentVideo),
            ],
          ),
        );
      //   break;
      default:
        return Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator());
    }
  }
}
