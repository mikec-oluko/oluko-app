import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:timelines/timelines.dart';
import 'coach_timeline_card_content.dart';
import 'coach_timeline_circle_content.dart';
import 'coach_timeline_video_content.dart';

class CoachTimelinePanel extends StatefulWidget {
  const CoachTimelinePanel({this.courseEnrollmentList});
  final List<CourseEnrollment> courseEnrollmentList;

  @override
  _CoachTimelinePanelConteState createState() => _CoachTimelinePanelConteState();
}

class _CoachTimelinePanelConteState extends State<CoachTimelinePanel> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: widget.courseEnrollmentList.length, vsync: this);
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
            tabs: widget.courseEnrollmentList
                .map((e) => Tab(
                      child: Container(
                        child: Text(e.course.name.toUpperCase(),
                            style: OlukoFonts.olukoMediumFont(
                                customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                      ),
                    ))
                .toList()),
      ),
      body: TabBarView(
          controller: _tabController,
          children: widget.courseEnrollmentList
              .map((course) => CoachTimelineCardContent(
                    cardTitle: course.course.name,
                    cardImage: course.course.image,
                    cardSubTitle: 'Counter 500',
                    date: '7:10 AM',
                    fileType: CoachFileTypeEnum.recommendedClass,
                  ))
              .toList()),
    );
  }
}
