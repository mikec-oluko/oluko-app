import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/search_suggestions.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class Courses extends StatefulWidget {
  Courses({Key key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<Courses> {
  List<Course> courses = [
    Course(
      imageUrl: 'assets/courses/course_sample_1.png',
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: OlukoAppBar(
          title: 'Courses',
          actions: [filterWidget()],
          onSearchResults: (SearchResults results) =>
              print(results.toJson().toString()),
          searchResultItems: [
            'buns of steel',
            'new year resolution',
            'stretching'
          ],
        ),
        bottomNavigationBar: OlukoBottomNavigationBar(),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Container(
              height: ScreenUtils.height(context),
              child: ListView(
                shrinkWrap: true,
                children: _mainPage(),
              ),
            )));
  }

  List<Widget> _mainPage() {
    return [
      Column(children: [
        CarouselSection(
          title: 'Active Courses',
          children: [
            getCourseCard('assets/courses/course_sample_1.png', progress: 0.3),
            getCourseCard('assets/courses/course_sample_2.png', progress: 0.7),
          ],
        ),
        CarouselSection(
          title: 'Back To Fitness',
          optionLabel: 'View All',
          children: [
            getCourseCard('assets/courses/course_sample_3.png'),
            getCourseCard('assets/courses/course_sample_4.png'),
            getCourseCard('assets/courses/course_sample_5.png'),
          ],
        ),
        CarouselSection(
          title: 'Push Your Limits',
          optionLabel: 'View All',
          children: [
            getCourseCard('assets/courses/course_sample_6.png'),
            getCourseCard('assets/courses/course_sample_7.png'),
            getCourseCard('assets/courses/course_sample_8.png'),
          ],
        )
      ])
    ];
  }

  Widget getCourseCard(String assetImage, {double progress}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: CourseCard(
        imageCover: Image.asset(assetImage),
        progress: progress,
      ),
    );
  }

  Widget filterWidget() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, top: 4),
      child: Icon(
        Icons.filter_alt_outlined,
        color: Colors.white,
        size: 25,
      ),
    );
  }
}
