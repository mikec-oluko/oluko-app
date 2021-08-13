import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/ui/screens/courses/class_segment_section.dart';

class ClassDetailSection extends StatefulWidget {
  final Class classObj;
  final List<Movement> movements;
  final Function(BuildContext, Movement) onPressedMovement;

  ClassDetailSection({
    this.classObj,
    this.onPressedMovement,
    this.movements,
  });

  @override
  _State createState() => _State();
}

class _State extends State<ClassDetailSection> {
  List<Movement> _movementsToShow = [];

  @override
  void initState() {
    super.initState();
    _movementsToShow = ClassService.getClassSegmentMovements(
        ClassService.getClassMovements(widget.classObj), widget.movements);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 400,
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/courses/gray_background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: ListView(children: getClassWidgets()));
  }

  List<Widget> getClassWidgets() {
    List<Widget> widgets = [
      Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Image.asset(
            'assets/courses/horizontal_vector.png',
            scale: 3,
          ))
    ];
    for (int i = 0; i < widget.classObj.segments.length; i++) {
      List<Movement> movements = ClassService.getClassSegmentMovements(
          widget.classObj.segments[i].movements, widget.movements);
      widgets.add(ClassSegmentSection(
          showTopDivider: i != 0,
          segmentSubmodel: widget.classObj.segments[i],
          movements: ClassService.getClassSegmentMovements(
              widget.classObj.segments[i].movements, movements),
          onPressedMovement: widget.onPressedMovement));
    }
    return widgets;
  }
}
