import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/ui/screens/courses/class_segment_section.dart';

class ClassDetailSection extends StatefulWidget {
  final Class classObj;
  final List<Segment> segments;
  final List<Movement> movements;
  final Function(BuildContext, Movement) onPressedMovement;

  ClassDetailSection({this.classObj, this.onPressedMovement, this.movements, this.segments});

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
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Image.asset(
                'assets/courses/horizontal_vector.png',
                scale: 3,
              )),
          Container(height: 448, child: ListView(children: getClassWidgets()))
        ]));
  }

  List<Widget> getClassWidgets() {
    List<Widget> widgets = [
      Container(
        height: 20,
      )
    ];
    for (int i = 0; i < widget.classObj.segments.length; i++) {
      List<Movement> movements = ClassService.getClassSegmentMovements(widget.classObj.segments[i].sections, widget.movements);
      widgets.add(ClassSegmentSection(
          showTopDivider: i != 0,
          segment: widget.segments.length - 1 >= i ? widget.segments[i] : null,
          movements: ClassService.getClassSegmentMovements(widget.classObj.segments[i].sections, movements),
          onPressedMovement: widget.onPressedMovement));//TODO:check null value
    }
    return widgets;
  }
}
