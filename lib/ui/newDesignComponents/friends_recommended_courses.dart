import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class FriendsRecommendedCourses extends StatefulWidget {
  final List<Map<String, List<UserResponse>>> listOfCoursesRecommended;
  final List<Course> courses;

  const FriendsRecommendedCourses({this.listOfCoursesRecommended, this.courses}) : super();

  @override
  State<FriendsRecommendedCourses> createState() => _FriendsRecommendedCoursesState();
}

class _FriendsRecommendedCoursesState extends State<FriendsRecommendedCourses> {
  double carouselSectionHeight;
  final double padding = OlukoNeumorphism.isNeumorphismDesign ? 0.65 : 0.2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    carouselSectionHeight = CourseUtils.getCarouselSectionHeight(context);

    return widget.listOfCoursesRecommended.isNotEmpty
        ? CarouselSection(
            optionLabel: OlukoLocalizations.get(context, 'viewAll'),
            onOptionTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.viewAll], arguments: {
                  'courses': widget.listOfCoursesRecommended
                      .map((courseRecommendedMapEntry) => CourseUtils.getCourseById(courseRecommendedMapEntry.keys.first, widget.courses))
                      .toList(),
                  'title': OlukoLocalizations.get(context, 'friendsRecommended')
                }),
            title: OlukoLocalizations.get(context, 'friendsRecommended'),
            height: carouselSectionHeight + 32,
            children: _getFriendsRecommendedCoursesList(widget.listOfCoursesRecommended))
        : const SizedBox.shrink();
  }

  List<Widget> _getFriendsRecommendedCoursesList(List<Map<String, List<UserResponse>>> coursesRecommendedMap) {
    return coursesRecommendedMap.map((Map<String, List<UserResponse>> courseRecommendedMapEntry) {
      Course courseRecommended = CourseUtils.getCourseById(courseRecommendedMapEntry.keys.first, widget.courses);
      return Padding(
        padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(vertical: 8, horizontal: 5) : const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
              arguments: {'course': courseRecommended, 'fromCoach': false, 'isCoachRecommendation': false}),
          child: _getCourseCard(CourseUtils.generateImageCourse(courseRecommended?.image, context),
              width: ScreenUtils.width(context) / (padding + CourseUtils.cardsToShow(context)),
              userRecommendations: courseRecommendedMapEntry.values.first,
              friendRecommended: true),
        ),
      );
    }).toList();
  }

  CourseCard _getCourseCard(Widget image,
      {double progress, double width, double height, List<UserResponse> userRecommendations, bool friendRecommended = false}) {
    return CourseCard(
        width: width, height: height, imageCover: image, progress: progress, userRecommendations: userRecommendations, friendRecommended: friendRecommended);
  }
}
