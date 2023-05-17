import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class SegmentSummaryComponent extends StatefulWidget {
  final int classIndex;
  final int segmentIndex;
  final List<SectionSubmodel> sectionsFromSegment;
  final bool addWeightEnable;
  final List<EnrollmentMovement> enrollmentMovements;
  final List<WeightRecord> weightRecords;
  final bool isResults;
  final bool useImperialSystem;
  final Function(bool) workoutHasWeights;
  final Function(List<WorkoutWeight> listOfWeigthsToUpdate) movementWeigths;

  const SegmentSummaryComponent(
      {this.classIndex,
      this.segmentIndex,
      this.enrollmentMovements,
      this.sectionsFromSegment,
      this.addWeightEnable = false,
      this.isResults = false,
      this.useImperialSystem = true,
      this.weightRecords,
      this.workoutHasWeights,
      this.movementWeigths})
      : super();

  @override
  State<SegmentSummaryComponent> createState() => _SegmentSummaryComponentState();
}

class _SegmentSummaryComponentState extends State<SegmentSummaryComponent> {
  bool keyboardVisibilty = false;
  Map<String, double> movementsWeights = {};
  List<WorkoutWeight> listOfWeigthsToUpdate = [];

  @override
  Widget build(BuildContext context) {
    return widget.isResults
        ? Scrollbar(
            isAlwaysShown: true,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _segmentSectionAndMovementDetails().length,
              itemBuilder: (c, i) => _segmentSectionAndMovementDetails()[i],
            ),
          )
        : Column(
            children: _segmentSectionAndMovementDetails(),
          );
  }

  List<Widget> _segmentSectionAndMovementDetails() {
    List<Widget> contentToReturn = [];
    if (widget.enrollmentMovements.isNotEmpty) {
      populateMovements(contentToReturn);
    }
    if (listOfWeigthsToUpdate.isNotEmpty) {
      widget.workoutHasWeights(true);
    }
    return contentToReturn;
  }

  void populateMovements(List<Widget> contentToReturn) {
    widget.sectionsFromSegment.forEach((section) {
      section.movements.forEach((movement) {
        if (MovementUtils.checkIfMovementRequireWeigth(movement, widget.enrollmentMovements)) {
          if (widget.addWeightEnable) {
            _createNewWeightRecord(section, movement);
            contentToReturn.add(_movementTileWithInput(movement));
          } else {
            contentToReturn.add(_movementTileWithWeightValue(movement));
          }
        } else {
          contentToReturn.add(_defaultMovementTile(movement));
        }
      });
    });
  }

  ListTile _defaultMovementTile(MovementSubmodel movement) {
    return ListTile(
      title: SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
    );
  }

  ListTile _movementTileWithWeightValue(MovementSubmodel movement) {
    return ListTile(
      trailing: getWeight(movement) == null
          ? const SizedBox.shrink()
          : Container(
              height: 40,
              decoration: const BoxDecoration(color: OlukoColors.grayColor, borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/courses/weight_icon.png',
                      scale: 3,
                    ),
                    Text(
                      widget.weightRecords.isNotEmpty ? double.parse(getWeight(movement)).round().toString() : '0',
                      style: OlukoFonts.olukoMediumFont(),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      widget.useImperialSystem ? OlukoLocalizations.get(context, 'lbs') : OlukoLocalizations.get(context, 'kgs'),
                      style: OlukoFonts.olukoMediumFont(),
                    )
                  ],
                ),
              ),
            ),
      title: SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
    );
  }

  String getWeight(MovementSubmodel movement) {
    String result;
    if (widget.weightRecords.isNotEmpty) {
      widget.weightRecords.forEach((weightRecord) {
        if (weightRecord.movementId == movement.id) {
          if (widget.useImperialSystem) {
            result = weightRecord.weight.toStringAsFixed(2);
          } else {
            result = (weightRecord.weight * _toKilogramsUnit).ceil().toStringAsFixed(2);
          }
        }
      });
    }
    return result;
  }

  double get _toKilogramsUnit => 0.453;

  Padding _movementTileWithInput(MovementSubmodel movement) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
          _inputComponent(movement.id),
        ],
      ),
    );
  }

  void _createNewWeightRecord(SectionSubmodel section, MovementSubmodel movement) {
    final WorkoutWeight newWeightHelper = WorkoutWeight(
        classIndex: widget.classIndex,
        segmentIndex: widget.segmentIndex,
        movementId: movement.id,
        sectionIndex: getSectionIndex(section),
        movementIndex: getMovementIndex(section, movement));
    if (!listOfWeigthsToUpdate.contains(newWeightHelper)) {
      listOfWeigthsToUpdate.add(newWeightHelper);
    }
  }

  Container _inputComponent(String movementId) {
    final WorkoutWeight currentMovementAndWeight = _getCurrentMovementAndWeight(movementId);
    return Container(
        decoration: const BoxDecoration(color: OlukoNeumorphismColors.appBackgroundColor, borderRadius: BorderRadius.all(Radius.circular(10))),
        width: 120,
        height: 40,
        child: TextFormField(
          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value == '') {
              movementsWeights[movementId] = null;
            } else {
              if (widget.useImperialSystem) {
                movementsWeights[movementId] = double.parse(value);
              } else {
                movementsWeights[movementId] = double.parse(value) * _passToKilogramsUnit;
              }
            }
            currentMovementAndWeight.weight = movementsWeights[movementId];
            widget.movementWeigths(listOfWeigthsToUpdate);
          },
          onTap: () {},
          onFieldSubmitted: (value) {
            if (value == '') {
              movementsWeights[movementId] = null;
            } else {
              if (widget.useImperialSystem) {
                movementsWeights[movementId] = double.parse(value);
              } else {
                movementsWeights[movementId] = double.parse(value) * _passToKilogramsUnit;
              }
            }
            currentMovementAndWeight.weight = movementsWeights[movementId];
            widget.movementWeigths(listOfWeigthsToUpdate);
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onEditingComplete: () {},
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: OlukoColors.white,
            fontWeight: FontWeight.bold,
          ),
          showCursor: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            focusColor: Colors.transparent,
            fillColor: Colors.transparent,
            hintText: OlukoLocalizations.get(context, 'addWeight'),
            hintStyle: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor),
            hintMaxLines: 1,
            border: InputBorder.none,
            suffixText: widget.useImperialSystem ? OlukoLocalizations.get(context, 'lbs') : OlukoLocalizations.get(context, 'kgs'),
          ),
        ));
  }

  double get _passToKilogramsUnit => 2.20462;

  WorkoutWeight _getCurrentMovementAndWeight(String movementId) => listOfWeigthsToUpdate.where((weightRecord) => weightRecord.movementId == movementId).first;

  int getMovementIndex(SectionSubmodel section, MovementSubmodel movement) => widget.sectionsFromSegment[getSectionIndex(section)].movements.indexOf(movement);

  int getSectionIndex(SectionSubmodel section) => widget.sectionsFromSegment.indexOf(section);
}
