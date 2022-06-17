import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/ui/screens/courses/class_segment_section.dart';

class ClassDetailSection extends StatefulWidget {
  final Class classObj;
  final List<Segment> segments;
  final List<Movement> movements;
  final Function(BuildContext, MovementSubmodel) onPressedMovement;
  final ChallengeNavigation segmentChallenge;

  ClassDetailSection({this.classObj, this.onPressedMovement, this.movements, this.segments, this.segmentChallenge});

  @override
  _State createState() => _State();
}

class _State extends State<ClassDetailSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/courses/gray_background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(children: [
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Image.asset(
                'assets/courses/horizontal_vector.png',
                scale: 5,
              )),
          Container(height: 448, child: ListView(children: getClassWidgets()))
        ]));
  }

  List<Widget> getClassWidgets() {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.classObj.segments.length; i++) {
      List<Movement> movements = ClassService.getClassSegmentMovements(widget.classObj.segments[i].sections, widget.movements);
      for (int j = 0; j < widget.segments.length; j++) {
        if (widget.segments[j].id == widget.classObj.segments[i].id && widget.segments[j].isChallenge == true) {
          for (int k = 0; k < widget.segmentChallenge.enrolledCourse.classes.length; k++) {
            if (widget.segmentChallenge.enrolledCourse.classes[k].id == widget.classObj.id) {
              if (i - 1 > 0) {
                widget.segmentChallenge.previousSegmentFinish =
                    widget.segmentChallenge.enrolledCourse.classes[k].segments[i - 1].completedAt != null;
                widget.segmentChallenge.challengeSegment = widget.segmentChallenge.enrolledCourse.classes[k].segments[i];
                widget.segmentChallenge.segmentIndex = i;
              } else {
                widget.segmentChallenge.segmentIndex = i;
                widget.segmentChallenge.previousSegmentFinish = true;
                widget.segmentChallenge.challengeSegment = widget.segmentChallenge.enrolledCourse.classes[k].segments[i];
              }
            }
          }
        }
      }
      widgets.add(ClassSegmentSection(
          segmentChallenge: widget.segmentChallenge,
          showTopDivider: i != 0,
          segment: widget.segments.length - 1 >= i ? widget.segments[i] : null,
          movements: ClassService.getClassSegmentMovements(widget.classObj.segments[i].sections, movements),
          movementSubmodels: ClassService.getClassSegmentMovementSubmodels(widget.classObj.segments[i].sections),
          onPressedMovement: widget.onPressedMovement)); //TODO:check null value
    }
    return widgets;
  }
}
