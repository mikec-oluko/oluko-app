import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/chat_course_icon.dart';

class ChatSlider extends StatefulWidget {
  final List<CourseEnrollment> courses;

  const ChatSlider({this.courses});

  @override
  _ChatSliderState createState() => _ChatSliderState();
}

class _ChatSliderState extends State<ChatSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView(
      children: widget.courses
          .map(
            (element) => GestureDetector(
              onTap: () => null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CourseIcon(
                    courseImage: element.course.image,
                    courseName: element.course.name,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ));
  }
}
