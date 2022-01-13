import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/unenroll_menu.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseCarouselGallery extends StatefulWidget {
  final List<CourseEnrollment> courseEnrollments;
  final int courseIndex;

  const CourseCarouselGallery({
    Key key,
    @required this.courseEnrollments,
    this.courseIndex,
  }) : super(key: key);

  @override
  _CourseCarouselGalleryState createState() => _CourseCarouselGalleryState();
}

class _CourseCarouselGalleryState extends State<CourseCarouselGallery> {
  List<Widget> items = [];

  @override
  void initState() {
    items = buildCourseCards(widget.courseIndex ?? 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: items,
      options: CarouselOptions(
          enlargeCenterPage: true,
          disableCenter: true,
          height: 185,
          enableInfiniteScroll: false,
          initialPage: widget.courseIndex ?? 0,
          onPageChanged: (index, reason) {
            setState(() {
              items = buildCourseCards(index);
            });
          }),
    );
  }

  List<Widget> buildCourseCards(int selected) {
    List<Widget> classCards = [];
    for (var i = 0; i < widget.courseEnrollments.length; i++) {
      classCards.add(SizedBox(
        height: getCourseCardHeight(selected, i),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.courseEnrollments[i].course.image),
            Positioned(
              top: 5,
              right: 3,
              child: UnenrollCourse(
                actualCourse: widget.courseEnrollments[selected],
              ),
            )
          ],
        ),
      ));
    }
  }

  double getCourseCardHeight(int selected, int i) {
    if (i == selected) {
      return ScreenUtils.height(context) / 2;
    } else {
      return ScreenUtils.height(context) * 0.4;
    }
  }
}
