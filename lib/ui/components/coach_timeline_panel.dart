import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/ui/components/coach_timeline_circle_content.dart';
import 'package:oluko_app/ui/components/coach_timeline_video_content.dart';
import 'package:oluko_app/ui/components/tab_content_list.dart';
// import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'coach_timeline_card_content.dart';

class CoachTimelinePanel extends StatefulWidget {
  const CoachTimelinePanel({this.contentTest});
  final List<CoachSegmentContent> contentTest;

  @override
  _CoachTimelinePanelConteState createState() => _CoachTimelinePanelConteState();
}

class _CoachTimelinePanelConteState extends State<CoachTimelinePanel> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Widget> contentList = [];
  List<List<Widget>> contentWithListNodes = [];

  @override
  void initState() {
    _tabController = TabController(length: widget.contentTest.length, vsync: this);
    splitContentWithDifferentContainers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: OlukoColors.black,
          flexibleSpace: Container(
            decoration: ContainerGradient.getContainerGradientDecoration(customBorder: true),
          ),
          automaticallyImplyLeading: false,
          // ignore: avoid_function_literals_in_foreach_calls
          bottom: TabBar(
              labelColor: OlukoColors.black,
              isScrollable: true,
              controller: _tabController,
              tabs: widget.contentTest
                  .map((content) => Tab(
                        child: Container(
                          child: Text(content.segmentName.toUpperCase(),
                              style: OlukoFonts.olukoMediumFont(
                                  customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                        ),
                      ))
                  .toList()),
        ),
        body: TabBarView(
          controller: _tabController,
          children: contentWithListNodes
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

  List<CoachTimelineCardContent> splitContentWithDifferentContainers() {
    widget.contentTest.forEach((element) {
      if (widget.contentTest[2] == element || widget.contentTest[5] == element) {
        contentList.add(CoachTimelineCircleContent(
          circleTitle: element.segmentName,
          circleImage: element.classImage,
          // circleSubTitle: 'Counter 500',
          date: '7:10 AM',
          fileType: CoachFileTypeEnum.recommendedMovement,
        ));
      } else if (widget.contentTest[1] == element || widget.contentTest[7] == element) {
        contentList.add(CoachTimelineVideoContent(
          videoTitle: element.segmentName,
          videoThumbnail: element.classImage,
          // circleSubTitle: 'Counter 500',
          date: '7:10 AM',
          fileType: CoachFileTypeEnum.mentoredVideo,
        ));
      } else {
        contentList.add(CoachTimelineCardContent(
          cardTitle: element.segmentName,
          cardImage: element.classImage,
          cardSubTitle: 'Counter 500',
          date: '7:10 AM',
          fileType: CoachFileTypeEnum.recommendedClass,
        ));
      }
    });
    contentList.forEach((elem) {
      contentWithListNodes.add(contentList);
    });
    print(contentWithListNodes);
  }
}
