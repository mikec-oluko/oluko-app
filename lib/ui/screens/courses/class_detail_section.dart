import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
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
  final Function(BuildContext, MovementSubmodel) onPressedMovement;
  final List<ChallengeNavigation> challengeNavigations;

  ClassDetailSection({this.challengeNavigations, this.classObj, this.onPressedMovement, this.segments});

  @override
  _State createState() => _State();
}

class _State extends State<ClassDetailSection> {
  @override
  void initState() {
    BlocProvider.of<MovementBloc>(context).getAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Movement> _movements = [];

    ChallengeNavigation getChallengeNavigation(int i, String segmentId) {
      for (var c in widget.challengeNavigations) {
        if (c.segmentId == segmentId) {
          return c;
        }
      }
      return null;
    }

    List<Widget> getClassWidgets() {
      List<Widget> widgets = [];
      for (int i = 0; i < widget.classObj.segments.length; i++) {
        if (widget.segments != null && widget.segments.length > i) {
          List<Movement> movements = ClassService.getClassSegmentMovements(widget.classObj.segments[i].sections, _movements);
          /*for (int j = 0; j < widget.segments.length; j++) {
          if (widget.segments[j].id == widget.classObj.segments[i].id && widget.segments[j].isChallenge == true) {
            for (int k = 0; k < widget.challengeNavigations[0].enrolledCourse.classes.length; k++) {
              if (widget.challengeNavigations[0].enrolledCourse.classes[k].id == widget.classObj.id) {
                if (i - 1 > 0) {
                  widget.challengeNavigations[0].previousSegmentFinish =
                      widget.challengeNavigations[0].enrolledCourse.classes[k].segments[i - 1].completedAt != null;
                  widget.challengeNavigations[0].challengeSegment = widget.challengeNavigations[0].enrolledCourse.classes[k].segments[i];
                  widget.challengeNavigations[0].segmentIndex = i;
                } else {
                  widget.challengeNavigations[0].segmentIndex = i;
                  widget.challengeNavigations[0].previousSegmentFinish = true;
                  widget.challengeNavigations[0].challengeSegment = widget.challengeNavigations[0].enrolledCourse.classes[k].segments[i];
                }
              }
            }
          }
        }*/
          widgets.add(ClassSegmentSection(
              challengeNavigation: getChallengeNavigation(i, widget.segments[i].id),
              showTopDivider: i != 0,
              segment: widget.segments.length - 1 >= i ? widget.segments[i] : null,
              movements: ClassService.getClassSegmentMovements(widget.classObj.segments[i].sections, movements),
              movementSubmodels: ClassService.getClassSegmentMovementSubmodels(widget.classObj.segments[i].sections),
              onPressedMovement: widget.onPressedMovement)); //TODO:check null value
        }
      }
      return widgets;
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          gradient: OlukoNeumorphism.olukoNeumorphicGradientDark(),
        ),
        child: Column(children: [
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Image.asset(
                'assets/courses/horizontal_vector.png',
                scale: 5,
              )),
          Container(
              height: 448,
              child: BlocBuilder<MovementBloc, MovementState>(builder: (context, movementState) {
                if (movementState is GetAllSuccess) {
                  _movements = movementState.movements;
                  return ListView(addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: getClassWidgets());
                } else {
                  return SizedBox();
                }
              }))
        ]));
  }
}
