import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/keyboard/keyboard_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class SegmentSummaryComponent extends StatefulWidget {
  final CourseEnrollment courseEnrollment;
  final Segment segment;
  final bool addWeightEnable;
  final EnrollmentSegment segmentFromCourseEnrollment;

  const SegmentSummaryComponent({this.courseEnrollment, this.segmentFromCourseEnrollment, this.segment, this.addWeightEnable = false}) : super();

  @override
  State<SegmentSummaryComponent> createState() => _SegmentSummaryComponentState();
}

class _SegmentSummaryComponentState extends State<SegmentSummaryComponent> {
  List<EnrollmentMovement> enrollmentMovements = [];
  TextEditingController textController;
  bool keyboardVisibilty = false;
  Map<String, double> movementsWeights = {};

  @override
  void initState() {
    setState(() {
      getMovementsFromEnrollmentSegment();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _segmentSectionAndMovementDetails(),
    );
  }

  List<Widget> _segmentSectionAndMovementDetails() {
    List<Widget> contentToReturn = [];
    if (enrollmentMovements.isNotEmpty) {
      populateMovements(contentToReturn);
    } else {
      getMovementsFromEnrollmentSegment();
      populateMovements(contentToReturn);
    }
    // widget.segments.forEach((segment) {
    // populateMovements(contentToReturn);
    // });
    return contentToReturn;
  }

  void populateMovements(List<Widget> contentToReturn) {
    widget.segment.sections.forEach((section) {
      section.movements.forEach((movement) {
        EnrollmentMovement _enrollmentMovemetInfo = enrollmentMovements.where((enrollmentMovement) => enrollmentMovement.id == movement.id).first;
        if (_enrollmentMovemetInfo.weightRequired) {
          if (widget.addWeightEnable) {
            contentToReturn.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
                  _inputComponent(movement.id),
                ],
                // trailing: _inputComponent(),
                // title: SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
              ),
            ));
          } else {
            contentToReturn.add(ListTile(
              trailing: Container(
                width: 70,
                height: 40,
                decoration: BoxDecoration(color: OlukoColors.grayColor, borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    Icon(Icons.search, color: OlukoColors.white),
                    Text(
                      '30',
                      style: OlukoFonts.olukoMediumFont(),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      'LBs',
                      style: OlukoFonts.olukoMediumFont(),
                    )
                  ],
                ),
              ),
              title: SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
            ));
          }
        } else {
          contentToReturn.add(ListTile(
            // trailing: Icon(Icons.cancel_outlined, color: OlukoColors.white),
            title: SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
          ));
        }
      });
    });
  }

  Container _inputComponent(String movementId) {
    return Container(
        decoration: BoxDecoration(color: OlukoNeumorphismColors.appBackgroundColor, borderRadius: const BorderRadius.all(Radius.circular(10))),
        width: 120,
        height: 40,
        child: TextField(
          keyboardType: TextInputType.number,
          onTap: () {
            setState(() {
              keyboardVisibilty = !keyboardVisibilty;
            });
          },
          onSubmitted: (value) {
            movementsWeights[movementId] = double.parse(value);
            print(movementsWeights);
          },
          onEditingComplete: () {
            print(movementsWeights);
          },
          textAlign: TextAlign.center,
          controller: textController,
          style: const TextStyle(
            fontSize: 20,
            color: OlukoColors.white,
            fontWeight: FontWeight.bold,
          ),
          showCursor: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 5),
            focusColor: Colors.transparent,
            fillColor: Colors.transparent,
            hintText: 'Add weight', //OlukoLocalizations.get(context, "enterScore"),
            hintStyle: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor),
            hintMaxLines: 1,
            border: InputBorder.none,
            suffixText: 'Kg',
          ),
        ));
  }

  getMovementsFromEnrollmentSegment() {
    widget.segmentFromCourseEnrollment.sections.forEach((enrollmentSection) {
      enrollmentSection.movements.forEach((enrollmentMovement) {
        enrollmentMovements.add(enrollmentMovement);
      });
    });
  }
}
