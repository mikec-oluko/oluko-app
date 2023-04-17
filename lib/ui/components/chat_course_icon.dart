import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/models/course_enrollment.dart';

class CourseIcon extends StatefulWidget {
  final String courseImage;
  final String courseName;

  const CourseIcon({this.courseImage, this.courseName});

  @override
  _CourseIconState createState() => _CourseIconState();
}

class _CourseIconState extends State<CourseIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(widget.courseImage),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget.courseName),
      ),
    );
  }
}
