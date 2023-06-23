import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MyListOfCourses extends StatefulWidget {
  final Map<CourseCategory, List<Course>> myListOfCourses;
  final Function(String courseId) beforeNavigation;
  const MyListOfCourses({this.myListOfCourses, this.beforeNavigation}) : super();

  @override
  State<MyListOfCourses> createState() => _MyListOfCoursesState();
}

class _MyListOfCoursesState extends State<MyListOfCourses> {
  final int cardsToShowOnPortrait = 3;
  final int cardsToShowOnLandscape = 4;
  final double padding = OlukoNeumorphism.isNeumorphismDesign ? 0.65 : 0.2;

  @override
  Widget build(BuildContext context) {
    final double carouselSectionHeight = CourseUtils.getCarouselSectionHeight(context);
    return _myListOfCourses(carouselSectionHeight);
  }

  Widget _myListOfCourses(double carouselSectionHeight) {
    return CarouselSection(
      optionLabel: OlukoLocalizations.get(context, 'viewAll'),
      onOptionTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.viewAll],
          arguments: {'courses': widget.myListOfCourses.values.toList().first, 'title': OlukoLocalizations.get(context, 'myList')}),
      title: OlukoLocalizations.get(context, 'myList'),
      height: Platform.isAndroid ? carouselSectionHeight -20 : 220,
      children: widget.myListOfCourses.values.isNotEmpty ? _getLikedCoursesList(widget.myListOfCourses) : [],
    );
  }

  List<Widget> _getLikedCoursesList(Map<CourseCategory, List<Course>> myListOfCourses) {
    if (myListOfCourses.values.toList().isNotEmpty) {
      return myListOfCourses.values.toList().first.map((courseElement) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 5),
          child: GestureDetector(
            onTap: () async {
              if (widget.beforeNavigation != null) widget.beforeNavigation(courseElement.id);
              Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                  arguments: {'course': courseElement, 'fromCoach': false, 'isCoachRecommendation': false});
            },
            child: _getCourseCard(
              CourseUtils.generateImageCourse(courseElement.image, context),
              width: ScreenUtils.width(context) / (padding + _cardsToShow()),
            ),
          ),
        );
      }).toList();
    } else {
      return [];
    }
  }

  CourseCard _getCourseCard(Widget image,
      {double progress, double width, double height, List<UserResponse> userRecommendations, bool friendRecommended = false}) {
    return CourseCard(
        width: width, height: height, imageCover: image, progress: progress, userRecommendations: userRecommendations, friendRecommended: friendRecommended);
  }

  int _cardsToShow() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return cardsToShowOnPortrait;
    } else {
      return cardsToShowOnLandscape;
    }
  }
}
