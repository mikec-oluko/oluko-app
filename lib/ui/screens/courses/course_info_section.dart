import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/ui/components/audio_section.dart';
import 'package:oluko_app/ui/components/course_poster.dart';
import 'package:oluko_app/ui/components/people_section.dart';
import 'package:oluko_app/ui/components/vertical_divider.dart' as verticalDivider;

class CourseInfoSection extends StatefulWidget {
  final int peopleQty;
  final int audioMessageQty;
  final String image;
  final Function() onAudioPressed;

  CourseInfoSection(
      {this.peopleQty, this.audioMessageQty, this.image, this.onAudioPressed});

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
            const SizedBox(height: 80),
            Row(children: [PeopleSection(peopleQty: widget.peopleQty), const verticalDivider.VerticalDivider(width: 48, height: 48,), AudioSection(audioMessageQty: widget.audioMessageQty, onAudioPressed: widget.onAudioPressed)])
          ])),
    ]);
  }
}
