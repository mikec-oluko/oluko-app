import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/class_card.dart';

class ClassCarouselGallery extends StatefulWidget {
  final CourseEnrollment courseEnrollment;

  const ClassCarouselGallery({
    Key key,
    @required this.courseEnrollment,
  }) : super(key: key);

  @override
  _ClassCarouselGalleryState createState() => _ClassCarouselGalleryState();
}

class _ClassCarouselGalleryState extends State<ClassCarouselGallery> {
  List<Widget> items = [];

  @override
  void initState() {
    items = buildClassCards(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: items,
      options: CarouselOptions(
          height: 225,
          autoPlay: false,
          enlargeCenterPage: false,
          disableCenter: false,
          enableInfiniteScroll: false,
          initialPage: 0,
          viewportFraction: 0.32,
          onPageChanged: (index, reason) {
            print("EL INDEX ES:" + index.toString());
            setState(() {
              items = buildClassCards(index);
            });
          }),
    );
  }

  List<Widget> buildClassCards(int selected) {
    List<Widget> classCards = [];
    for (var i = 0; i < widget.courseEnrollment.classes.length; i++) {
      classCards.add(ClassCard(
        enrollmentClass: widget.courseEnrollment.classes[i],
        classIndex: i,
        courseEnrollment: widget.courseEnrollment,
        selected: i == selected ? true : false,
      ));
    }
    return classCards;
  }
}
