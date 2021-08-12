import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/ui/components/course_poster.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CourseInfoSection extends StatefulWidget {
  final int peopleQty;
  final int audioMessageQty;
  final String image;

  CourseInfoSection({this.peopleQty, this.audioMessageQty, this.image});

  @override
  _State createState() => _State();
}

class _State extends State<CourseInfoSection> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
          padding: const EdgeInsets.only(left: 15),
          child: CoursePoster(image: widget.image)),
      Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Column(children: [
            SizedBox(height: 80),
            Row(children: [peopleSection(), verticalDivider(), audioSection()])
          ])),
    ]);
  }

  Widget peopleSection() {
    return Column(children: [
      Text(
        widget.peopleQty.toString() + "+",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      SizedBox(height: 5),
      Text(
        OlukoLocalizations.of(context).find('inThis'),
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      ),
      Text(
        OlukoLocalizations.of(context).find('course').toLowerCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      ),
    ]);
  }

  Widget audioSection() {
    return Stack(alignment: Alignment.topRight, children: [
      Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Image.asset(
            'assets/courses/audio.png',
            height: 50,
            width: 50,
          )),
      Stack(alignment: Alignment.center, children: [
        Image.asset(
          'assets/courses/audio_notification.png',
          height: 22,
          width: 22,
        ),
        Text(
          widget.audioMessageQty.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w300, color: Colors.white),
        )
      ]),
    ]);
  }

  Widget verticalDivider() {
    return Image.asset(
      'assets/courses/vertical_divider.png',
      height: 48,
      width: 48,
    );
  }
}
