import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/max_weight.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/ui/components/custom_keyboard.dart';
import 'package:oluko_app/ui/newDesignComponents/weight_tile_for_value.dart';
import 'package:oluko_app/ui/newDesignComponents/weight_tile_with_input.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class SegmentDetailsComponent extends StatefulWidget {
  final int classIndex;
  final int segmentIndex;
  final String segmentId;
  final bool segmentSaveMaxWeights;
  final List<SectionSubmodel> sectionsFromSegment;
  final bool addWeightEnable;
  final List<EnrollmentMovement> enrollmentMovements;
  final List<MaxWeight> maxWeightRecords;
  final List<WeightRecord> weightRecords;
  final bool isResults;
  final bool useImperialSystem;
  final Function(bool) workoutHasWeights;
  final Function(List<WorkoutWeight> listOfWeightsToUpdate, bool segmentSaveMaxWeights) movementWeights;

  const SegmentDetailsComponent(
      {this.classIndex,
      this.segmentIndex,
      this.segmentId,
      this.segmentSaveMaxWeights,
      this.enrollmentMovements,
      this.sectionsFromSegment,
      this.maxWeightRecords,
      this.addWeightEnable = false,
      this.isResults = false,
      this.useImperialSystem = true,
      this.weightRecords,
      this.workoutHasWeights,
      this.movementWeights})
      : super();

  @override
  State<SegmentDetailsComponent> createState() => _SegmentDetailsComponentState();
}

class _SegmentDetailsComponentState extends State<SegmentDetailsComponent> {
  bool keyboardVisibilty = false;
  Map<String, int> movementsWeights = {};
  List<WorkoutWeight> listOfWeightsToUpdate = [];
  bool showRecommendation = false;
  bool segmentHasRecommendations = false;
  bool segmentHasWeights = false;
  final List<TextEditingController> _listOfControllers = [];
  final List<FocusNode> _listOfNodes = [];

  @override
  void initState() {
    setState(() {
      if (!widget.addWeightEnable) {
        showRecommendation = segmentHasRecommendations;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in _listOfControllers) {
      controller.dispose();
    }
    for (final controller in _listOfNodes) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: _segmentSectionAndMovementDetails(false),
        ),
      ],
    );
  }

  List<Widget> _segmentSectionAndMovementDetails(bool showWeightRecommendation) {
    // ignore: prefer_final_locals
    List<Widget> contentToReturn = [];
    if (widget.enrollmentMovements.isNotEmpty) {
      populateMovements(contentToReturn, showWeightRecommendation);
    }
    if (listOfWeightsToUpdate.isNotEmpty) {
      widget.workoutHasWeights(true);
    }
    return contentToReturn;
  }

  void populateMovements(List<Widget> contentToReturn, bool showWeightRecommendation) {
    widget.sectionsFromSegment.forEach((section) {
      section.movements.forEach(
        (movement) {
          if (MovementUtils.checkIfMovementRequireWeight(movement, widget.enrollmentMovements)) {
            contentToReturn.add(
              WeightTileForValue(
                movement: movement,
                segmentId: widget.segmentId,
                showWeightRecommendation: showWeightRecommendation,
                percentageOfMaxWeight: movement.percentOfMaxWeight,
                maxWeightValue: MovementUtils.getMaxWeightForMovement(movement, widget.maxWeightRecords) != 0
                    ? double.parse(MovementUtils.getMaxWeightForMovement(movement, widget.maxWeightRecords).toString())
                    : null,
                weightRecords: widget.weightRecords,
                useImperialSystem: widget.useImperialSystem,
              ),
            );
          } else {
            contentToReturn.add(_defaultMovementTile(movement));
          }
        },
      );
    });
  }

  ListTile _defaultMovementTile(MovementSubmodel movement) {
    return ListTile(
      title: SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
    );
  }

  double get _passToKilogramsUnit => 2.20462;

  int getMovementIndex(SectionSubmodel section, MovementSubmodel movement) => widget.sectionsFromSegment[getSectionIndex(section)].movements.indexOf(movement);

  int getSectionIndex(SectionSubmodel section) => widget.sectionsFromSegment.indexOf(section);
}
