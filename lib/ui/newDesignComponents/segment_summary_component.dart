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
import 'package:oluko_app/ui/newDesignComponents/weight_tile_for_value.dart';
import 'package:oluko_app/ui/newDesignComponents/weight_tile_with_input.dart';
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
            contentToReturn.add(WeightTileForValue(
              movement: movement,
              weightRecords: widget.weightRecords,
              useImperialSystem: widget.useImperialSystem,
            ));
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

  Widget _movementTileWithInput(MovementSubmodel movement) {
    final WorkoutWeight currentMovementAndWeight = _getCurrentMovementAndWeight(movement.id);
    return WeightTileWithInput(
      movement: movement,
      useImperialSystem: widget.useImperialSystem,
      onChangeAction: (value) {
        _onChangeWeightInputValue(value, movement, currentMovementAndWeight);
      },
      onSubmitAction: (value) {
        _onSubmitWeightValue(value, movement, currentMovementAndWeight);
      },
    );
  }

  void _onChangeWeightInputValue(String value, MovementSubmodel movement, WorkoutWeight currentMovementAndWeight) {
    if (value == '') {
      movementsWeights[movement.id] = null;
    } else {
      if (widget.useImperialSystem) {
        movementsWeights[movement.id] = double.parse(value);
      } else {
        movementsWeights[movement.id] = double.parse(value) * _passToKilogramsUnit;
      }
    }
    currentMovementAndWeight.weight = movementsWeights[movement.id];
    widget.movementWeigths(listOfWeigthsToUpdate);
  }

  void _onSubmitWeightValue(String value, MovementSubmodel movement, WorkoutWeight currentMovementAndWeight) {
    if (value == '') {
      movementsWeights[movement.id] = null;
    } else {
      if (widget.useImperialSystem) {
        movementsWeights[movement.id] = double.parse(value);
      } else {
        movementsWeights[movement.id] = double.parse(value) * _passToKilogramsUnit;
      }
    }
    currentMovementAndWeight.weight = movementsWeights[movement.id];
    widget.movementWeigths(listOfWeigthsToUpdate);
    FocusManager.instance.primaryFocus?.unfocus();
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

  double get _passToKilogramsUnit => 2.20462;

  WorkoutWeight _getCurrentMovementAndWeight(String movementId) => listOfWeigthsToUpdate.where((weightRecord) => weightRecord.movementId == movementId).first;

  int getMovementIndex(SectionSubmodel section, MovementSubmodel movement) => widget.sectionsFromSegment[getSectionIndex(section)].movements.indexOf(movement);

  int getSectionIndex(SectionSubmodel section) => widget.sectionsFromSegment.indexOf(section);
}
