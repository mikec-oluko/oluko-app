import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/ui/components/coach_timeline_circle_content.dart';
import 'package:oluko_app/ui/components/coach_timeline_video_content.dart';
import 'package:oluko_app/ui/components/tab_content_list.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'coach_timeline_card_content.dart';

class CoachTimelinePanel extends StatefulWidget {
  const CoachTimelinePanel({this.timelineContentItems});
  final List<CoachTimelineGroup> timelineContentItems;

  @override
  _CoachTimelinePanelConteState createState() => _CoachTimelinePanelConteState();
}

class _CoachTimelinePanelConteState extends State<CoachTimelinePanel> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Widget> contentList = [];
  List<List<Widget>> contentWithListNodes = [];

  @override
  void initState() {
    setState(() {
      _tabController = TabController(length: widget.timelineContentItems.length, vsync: this);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController.length != widget.timelineContentItems.length) {
      _tabController = TabController(length: widget.timelineContentItems.length, vsync: this);
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: OlukoColors.black,
          flexibleSpace: Container(
            decoration: ContainerGradient.getContainerGradientDecoration(customBorder: true),
          ),
          automaticallyImplyLeading: false,
          bottom: TabBar(
              labelColor: OlukoColors.black,
              isScrollable: true,
              controller: _tabController,
              tabs: widget.timelineContentItems
                  .map((content) => Tab(
                        child: Container(
                          child: Text(content.courseName.toUpperCase(),
                              style: OlukoFonts.olukoMediumFont(
                                  customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                        ),
                      ))
                  .toList()),
        ),
        body: TabBarView(
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
        ));
  }

  List<List<Widget>> passContentToWidgets() {
    Widget widgetTypeToUse;
    List<Widget> listOfWidgets = [];
    List<List<Widget>> finalListOfWidgetContent = [];
    widget.timelineContentItems.forEach((content) {
      content.timelineElements.forEach((element) {
        widgetTypeToUse = getWidgedToUse(element);
        listOfWidgets.add(widgetTypeToUse);
      });
      finalListOfWidgetContent.insert(widget.timelineContentItems.indexOf(content), listOfWidgets);
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
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateForContent,
              CoachTimelineCardContent(
                cardImage: content.contentThumbnail,
                cardTitle: content.contentName,
                cardSubTitle: '',
                date: content.createdAt.toDate(),
                fileType: CoachFileTypeEnum.recommendedCourse,
              ),
            ],
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
        return Container(
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
    }
  }
}
