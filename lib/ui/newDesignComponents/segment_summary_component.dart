import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/ui/newDesignComponents/weight_tile_for_value.dart';
import 'package:oluko_app/ui/newDesignComponents/weight_tile_with_input.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class SegmentSummaryComponent extends StatefulWidget {
  final int classIndex;
  final int segmentIndex;
  final String segmentId;
  final bool segmentSaveMaxWeights;
  final List<SectionSubmodel> sectionsFromSegment;
  final bool addWeightEnable;
  final List<EnrollmentMovement> enrollmentMovements;
  final List<WeightRecord> weightRecords;
  final bool isResults;
  final bool useImperialSystem;
  final Function(bool) workoutHasWeights;
  final Function(List<WorkoutWeight> listOfWeigthsToUpdate, bool segmentSaveMaxWeights) movementWeights;

  const SegmentSummaryComponent(
      {this.classIndex,
      this.segmentIndex,
      this.segmentId,
      this.segmentSaveMaxWeights,
      this.enrollmentMovements,
      this.sectionsFromSegment,
      this.addWeightEnable = false,
      this.isResults = false,
      this.useImperialSystem = true,
      this.weightRecords,
      this.workoutHasWeights,
      this.movementWeights})
      : super();

  @override
  State<SegmentSummaryComponent> createState() => _SegmentSummaryComponentState();
}

class _SegmentSummaryComponentState extends State<SegmentSummaryComponent> {
  bool keyboardVisibilty = false;
  Map<String, double> movementsWeights = {};
  List<WorkoutWeight> listOfWeigthsToUpdate = [];
  bool showRecommendation = false;

  @override
  Widget build(BuildContext context) {
    return widget.isResults
        ? Scrollbar(
            isAlwaysShown: true,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _segmentSectionAndMovementDetails(showRecommendation).isNotEmpty ? _segmentSectionAndMovementDetails(showRecommendation).length : 1,
              itemBuilder: (c, i) => _segmentSectionAndMovementDetails(showRecommendation)[i],
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Neumorphic(
                  style: OlukoNeumorphism.getNeumorphicStyleForStadiumShapeElement(),
                  child: Container(
                    height: 60,
                    width: ScreenUtils.width(context) - 40,
                    decoration:
                        BoxDecoration(color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth, borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showRecommendation = false;
                            });
                          },
                          child: Container(
                            height: 60,
                            width: (ScreenUtils.width(context) - 80) / 2,
                            decoration: BoxDecoration(
                                color: showRecommendation ? OlukoNeumorphismColors.appBackgroundColor : OlukoColors.primaryLight,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), bottomLeft: Radius.circular(50))),
                            child: Center(
                              child: Text(OlukoLocalizations.get(context, 'recentWeight'),
                                  style: OlukoFonts.olukoMediumFont(
                                      customFontWeight: FontWeight.w500,
                                      customColor: showRecommendation ? OlukoColors.white : OlukoNeumorphismColors.appBackgroundColor)),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showRecommendation = true;
                            });
                          },
                          child: Container(
                            height: 60,
                            color: showRecommendation ? OlukoColors.primary : OlukoNeumorphismColors.appBackgroundColor,
                            width: (ScreenUtils.width(context) - 80) / 2,
                            child: Center(
                              child: Text(OlukoLocalizations.get(context, 'recommended'),
                                  style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.white)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: _segmentSectionAndMovementDetails(showRecommendation),
              ),
            ],
          );
  }

  List<Widget> _segmentSectionAndMovementDetails(bool showWeightRecommendation) {
    List<Widget> contentToReturn = [];
    if (widget.enrollmentMovements.isNotEmpty) {
      populateMovements(contentToReturn, showWeightRecommendation);
    }
    if (listOfWeigthsToUpdate.isNotEmpty) {
      widget.workoutHasWeights(true);
    }
    return contentToReturn;
  }

  void populateMovements(List<Widget> contentToReturn, bool showWeightRecommendation) {
    widget.sectionsFromSegment.forEach((section) {
      section.movements.forEach((movement) {
        if (MovementUtils.checkIfMovementRequireWeigth(movement, widget.enrollmentMovements)) {
          if (widget.addWeightEnable) {
            _createNewWeightRecord(section, movement);
            contentToReturn.add(_movementTileWithInput(movement));
          } else {
            contentToReturn.add(WeightTileForValue(
              movement: movement,
              segmentId: widget.segmentId,
              showWeightRecommendation: showWeightRecommendation,
              percentageOfMaxWeight: movement.percentOfMaxWeight,
              maxWeightValue: 100, //TODO: Replace with value from MAX_WEIGHT BLOC
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
    widget.movementWeights(listOfWeigthsToUpdate, widget.segmentSaveMaxWeights);
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
    widget.movementWeights(listOfWeigthsToUpdate, widget.segmentSaveMaxWeights);
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
