import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/ui/components/course_poster.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CourseInfoSection extends StatefulWidget {
  final int peopleQty;
  final int audioMessageQty;
  final String image;
  final Function() onAudioPressed;
  final Function() onPeoplePressed;
  final Function() clockAction;

  CourseInfoSection({this.peopleQty, this.audioMessageQty, this.image, this.onPeoplePressed, this.onAudioPressed, this.clockAction});

  @override
  _State createState() => _State();
}

class _State extends State<CourseInfoSection> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(padding: const EdgeInsets.only(left: 15), child: CoursePoster(image: widget.image)),
      Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Column(children: [
            SizedBox(height: 80),
            Row(children: [
              widget.peopleQty != null ? GestureDetector(onTap: widget.onPeoplePressed, child: peopleSection()) : SizedBox(),
              verticalDivider(),
              widget.audioMessageQty != null
                  ? GestureDetector(
                      onTap: widget.onAudioPressed, child: audioSection(context))
                  : SizedBox(),
              widget.clockAction != null
                  ? GestureDetector(
                      onTap: widget.clockAction, child: clockSection())
                  : SizedBox(),
            ])
          ])),
    ]);
  }

  Widget clockSection() {
    return Container(
      width: 60,
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Image.asset(
              'assets/courses/clock.png',
              height: 24,
              width: 27,
            )),
        const SizedBox(height: 5),
        Text(
          OlukoLocalizations.get(context, 'personalRecord'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
        )
      ]),
    );
  }

  Widget peopleSection() {
    return Column(children: [
      Text(
        widget.peopleQty.toString() + "+",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      SizedBox(height: 5),
      Text(
        OlukoLocalizations.get(context, 'inThis'),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      ),
      Text(
        OlukoLocalizations.get(context, 'course').toLowerCase(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      ),
    ]);
  }

  Widget audioSection(BuildContext context) {
    return GestureDetector(
        onTap: widget.audioMessageQty != null && widget.audioMessageQty > 0 ? widget.onAudioPressed : null,
        child: Stack(alignment: Alignment.topRight, children: [
          Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Image.asset(
                'assets/courses/audio.png',
                height: 50,
                width: 50,
              )),
          widget.audioMessageQty != null && widget.audioMessageQty > 0
              ? Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/courses/audio_notification.png',
                    height: 22,
                    width: 22,
                  ),
                  Text(
                    widget.audioMessageQty.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300, color: Colors.white),
                  ),
                ])
              : SizedBox(),
        ]));
  }

  Widget verticalDivider() {
    return Image.asset(
      'assets/courses/vertical_divider.png',
      height: 48,
      width: 48,
    );
  }
}
