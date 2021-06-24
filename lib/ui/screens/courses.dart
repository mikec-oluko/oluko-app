import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class Courses extends StatefulWidget {
  Courses({Key key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<Courses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: OlukoAppBar(
          title: 'Courses',
          actions: [filterWidget()],
        ),
        bottomNavigationBar: OlukoBottomNavigationBar(),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              height: ScreenUtils.height(context),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Column(
                    children: [
                      SearchBar(),
                      Divider(
                        height: 40,
                        color: Colors.white12,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      CarouselSection(
                        title: 'Active Courses',
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: CourseCard(
                              progress: 0.3,
                              imageCover: Image.asset(
                                  'assets/courses/course_sample_1.png'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: CourseCard(
                              progress: 0.7,
                              imageCover: Image.asset(
                                  'assets/courses/course_sample_2.png'),
                            ),
                          ),
                        ],
                      ),
                      CarouselSection(
                        title: 'Back To Fitness',
                        optionLabel: 'View All',
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: CourseCard(
                              imageCover: Image.asset(
                                  'assets/courses/course_sample_3.png'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: CourseCard(
                              imageCover: Image.asset(
                                  'assets/courses/course_sample_4.png'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: CourseCard(
                              imageCover: Image.asset(
                                  'assets/courses/course_sample_5.png'),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            )));
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
