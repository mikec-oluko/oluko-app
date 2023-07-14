import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/max_weight.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';
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

class SegmentSummaryComponent extends StatefulWidget {
  final int classIndex;
  final int segmentIndex;
  final String segmentId;
  final List<SectionSubmodel> sectionsFromSegment;
  final bool addWeightEnable;
  final List<EnrollmentMovement> enrollmentMovements;
  final List<EnrollmentSection> sectionsFromEnrollment;
  final List<MaxWeight> maxWeightRecords;
  final List<WeightRecord> weightRecords;
  final bool isResults;
  final bool useImperialSystem;
  final EdgeInsets paddingForInput;
  final Function(bool) workoutHasWeights;
  final Function(List<WorkoutWeight> listOfWeightsToUpdate) movementWeights;
  final Function(bool usePersonalRecord) segmentHasPersonalRecordMovement;
  final GlobalKey<TooltipState> tooltipKey;

  const SegmentSummaryComponent({
    this.classIndex,
    this.segmentIndex,
    this.segmentId,
    this.enrollmentMovements,
    this.sectionsFromEnrollment,
    this.sectionsFromSegment,
    this.maxWeightRecords,
    this.addWeightEnable = false,
    this.isResults = false,
    this.useImperialSystem = true,
    this.weightRecords,
    this.workoutHasWeights,
    this.movementWeights,
    this.segmentHasPersonalRecordMovement,
    this.tooltipKey,
    this.paddingForInput = EdgeInsets.zero,
  }) : super();

  @override
  State<SegmentSummaryComponent> createState() => _SegmentSummaryComponentState();
}

class _SegmentSummaryComponentState extends State<SegmentSummaryComponent> {
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
        segmentHasWeights = segmentUseWeights();
        segmentHasRecommendations = segmentHasWeightRecommendations();
        showRecommendation = segmentHasRecommendations;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _listOfControllers) {
      controller.dispose();
    }
    for (var controller in _listOfNodes) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isResults
        ? Scrollbar(
            isAlwaysShown: true,
            child: ListView.builder(
              physics: OlukoNeumorphism.listViewPhysicsEffect,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _segmentSectionAndMovementDetails(showRecommendation).isNotEmpty ? _segmentSectionAndMovementDetails(showRecommendation).length : 1,
              itemBuilder: (c, i) => _segmentSectionAndMovementDetails(showRecommendation)[i],
            ),
          )
        : Column(
            children: [
              weightTabsComponent(context),
              Column(
                children: _segmentSectionAndMovementDetails(showRecommendation),
              ),
            ],
          );
  }

  Widget weightTabsComponent(BuildContext context) {
    if (segmentHasRecommendations && segmentHasWeights) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Neumorphic(
          style: OlukoNeumorphism.getNeumorphicStyleForStadiumShapeElement(),
          child: Container(
            height: 60,
            width: ScreenUtils.width(context) - 40,
            decoration: const BoxDecoration(color: OlukoNeumorphismColors.appBackgroundColor, borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Row(
              children: [_loggedWeightComponent(context), _recommendedWeightComponent(context)],
            ),
          ),
        ),
      );
    } else if (segmentHasWeights && !segmentHasRecommendations) {
      setState(() {
        showRecommendation = false;
      });
      return Container(
        height: 20,
        width: ScreenUtils.width(context) - 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(OlukoLocalizations.get(context, 'loggedWeight'),
                style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.white))
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  GestureDetector _recommendedWeightComponent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showRecommendation = true;
        });
      },
      child: Container(
        height: 60,
        color: showRecommendation ? OlukoColors.primary : OlukoNeumorphismColors.appBackgroundColor,
        width: (ScreenUtils.width(context)) * 0.35,
        child: Center(
          child: Text(OlukoLocalizations.get(context, 'recommended'),
              style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.white)),
        ),
      ),
    );
  }

  GestureDetector _loggedWeightComponent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showRecommendation = false;
        });
      },
      child: Container(
        height: 60,
        width: (ScreenUtils.width(context) - 100) / 2,
        decoration: BoxDecoration(
            color: showRecommendation ? OlukoNeumorphismColors.appBackgroundColor : OlukoColors.primaryLight,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), bottomLeft: Radius.circular(50))),
        child: Center(
          child: Text(OlukoLocalizations.get(context, 'loggedWeight'),
              style: OlukoFonts.olukoMediumFont(
                  customFontWeight: FontWeight.w500, customColor: showRecommendation ? OlukoColors.white : OlukoNeumorphismColors.appBackgroundColor)),
        ),
      ),
    );
  }

  List<Widget> _segmentSectionAndMovementDetails(bool showWeightRecommendation) {
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
    int controllersIndex = 0;
    for (var sectionIndex = 0; sectionIndex < widget.sectionsFromEnrollment.length; sectionIndex++) {
      final SectionSubmodel currentSection = getCurrentSection(sectionIndex);
      for (var movementIndex = 0; movementIndex < widget.sectionsFromEnrollment[sectionIndex].movements.length; movementIndex++) {
        final MovementSubmodel currentMovement = getCurrentMovement(sectionIndex, movementIndex);
        final EnrollmentMovement currentEnrollmentMovement = getCurrentEnrollmentMovement(sectionIndex, movementIndex, currentMovement.id);
        if (MovementUtils.checkIfMovementRequireWeight(currentMovement, widget.enrollmentMovements)) {
          if (widget.addWeightEnable) {
            if (currentEnrollmentMovement.personalRecord) {
              widget.segmentHasPersonalRecordMovement(true);
            }
            _createNewWeightRecord(currentSection, currentMovement, currentEnrollmentMovement);
            _listOfControllers.add(TextEditingController());
            _listOfNodes.add(FocusNode());
            contentToReturn.add(_movementTileWithInput(currentMovement, currentEnrollmentMovement, _listOfControllers[controllersIndex],
                _listOfNodes[controllersIndex], getSectionIndex(currentSection)));
            controllersIndex++;
          } else {
            contentToReturn.add(WeightTileForValue(
              movement: currentMovement,
              segmentId: widget.segmentId,
              sectionIndex: getSectionIndex(currentSection),
              showWeightRecommendation: showWeightRecommendation,
              percentageOfMaxWeight: currentMovement.percentOfMaxWeight,
              maxWeightValue: MovementUtils.getMaxWeightForMovement(currentMovement, widget.maxWeightRecords) == null
                  ? 0
                  : double.parse(MovementUtils.getMaxWeightForMovement(currentMovement, widget.maxWeightRecords).toString()),
              weightRecords: widget.weightRecords,
              useImperialSystem: widget.useImperialSystem,
            ));
          }
        } else {
          contentToReturn.add(_defaultMovementTile(currentMovement));
        }
      }
    }
  }

  EnrollmentMovement getCurrentEnrollmentMovement(int sectionIndex, int movementIndex, String movementId) =>
      widget.sectionsFromEnrollment[sectionIndex].movements.firstWhere((enrolledMovement) => enrolledMovement.id == movementId);

  MovementSubmodel getCurrentMovement(int sectionIndex, int movementIndex) => widget.sectionsFromSegment[sectionIndex].movements[movementIndex];

  SectionSubmodel getCurrentSection(int sectionIndex) => widget.sectionsFromSegment[sectionIndex];

  Widget _defaultMovementTile(MovementSubmodel movement) {
    return Container(
      padding: widget.paddingForInput,
      height: 40,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: SizedBox(
          width: ScreenUtils.width(context) / 2,
          child: Text(SegmentUtils.getLabel(movement),
              maxLines: 2, style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor)),
        ),
      ),
    );
  }

  Widget _movementTileWithInput(
      MovementSubmodel movement, EnrollmentMovement enrollmentMovement, TextEditingController textController, FocusNode _listOfNodes, int sectionIndex) {
    final WorkoutWeight currentMovementAndWeight = _getCurrentMovementAndWeight(movement.id, sectionIndex);
    return WeightTileWithInput(
      movement: movement,
      enrollmentMovement: enrollmentMovement,
      currentTextEditingController: textController,
      open: (focusNode, textEditingController) => open(movement.id, currentMovementAndWeight, textEditingController, focusNode),
      useImperialSystem: widget.useImperialSystem,
      tooltipKey: widget.tooltipKey,
    );
  }

  void _onChangeWeightInputValue(String value, MovementSubmodel movement, WorkoutWeight currentMovementAndWeight) {
    if (value == '') {
      movementsWeights[movement.id] = null;
    } else {
      if (widget.useImperialSystem) {
        movementsWeights[movement.id] = int.parse(value);
      } else {
        movementsWeights[movement.id] = MovementUtils.lbsToKilogram(int.parse(value));
      }
    }
    currentMovementAndWeight.weight = movementsWeights[movement.id];
    widget.movementWeights(listOfWeightsToUpdate);
  }

  void _onSubmitWeightValue(String value, MovementSubmodel movement, WorkoutWeight currentMovementAndWeight) {
    if (value == '') {
      movementsWeights[movement.id] = null;
    } else {
      if (widget.useImperialSystem) {
        movementsWeights[movement.id] = int.parse(value);
      } else {
        movementsWeights[movement.id] = MovementUtils.lbsToKilogram(int.parse(value));
      }
    }
    currentMovementAndWeight.weight = movementsWeights[movement.id];
    widget.movementWeights(listOfWeightsToUpdate);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _createNewWeightRecord(SectionSubmodel section, MovementSubmodel movement, EnrollmentMovement enrolledMovement) {
    final WorkoutWeight newWeightHelper = WorkoutWeight(
        classIndex: widget.classIndex,
        segmentIndex: widget.segmentIndex,
        movementId: movement.id,
        sectionIndex: getSectionIndex(section),
        movementIndex: getMovementIndex(section, movement),
        setMaxWeight: enrolledMovement.setMaxWeight,
        isPersonalRecord: enrolledMovement.personalRecord);
    if (!listOfWeightsToUpdate.contains(newWeightHelper)) {
      listOfWeightsToUpdate.add(newWeightHelper);
    }
  }

  double get _passToKilogramsUnit => 2.20462;

  WorkoutWeight _getCurrentMovementAndWeight(String movementId, int sectionIndex) =>
      listOfWeightsToUpdate.where((weightRecord) => weightRecord.movementId == movementId && weightRecord.sectionIndex == sectionIndex).first;

  int getMovementIndex(SectionSubmodel section, MovementSubmodel movement) => widget.sectionsFromSegment[getSectionIndex(section)].movements.indexOf(movement);

  int getSectionIndex(SectionSubmodel section) => widget.sectionsFromSegment.indexOf(section);

  void open(String movementId, WorkoutWeight currentMovementAndWeight, TextEditingController textEditingController, FocusNode focusNode) {
    _listOfNodes.forEach((element) {
      if (element.hasFocus) {
        element.unfocus();
      }
    });

    focusNode.requestFocus();

    BottomDialogUtils.showBottomDialog(
      barrierColor: false,
      context: context,
      content: CustomKeyboard(
        boxDecoration: OlukoNeumorphism.boxDecorationForKeyboard(),
        controller: textEditingController,
        focus: focusNode,
        limitLength: true,
        maxLengthValue: 4,
        onChanged: () => onSubmit(movementId, currentMovementAndWeight, textEditingController),
        onSubmit: () {
          onSubmit(movementId, currentMovementAndWeight, textEditingController);
          Navigator.pop(context);
          focusNode.unfocus();
        },
      ),
    );
  }

  void onSubmit(String movementId, WorkoutWeight currentMovementAndWeight, TextEditingController textEditingController) {
    if (textEditingController.text == '') {
      movementsWeights[movementId] = null;
    } else {
      if (widget.useImperialSystem) {
        movementsWeights[movementId] = int.parse(textEditingController.text);
      } else {
        movementsWeights[movementId] = MovementUtils.kilogramToLbs(int.parse(textEditingController.text));
      }
    }
    currentMovementAndWeight.weight = movementsWeights[movementId];

    widget.movementWeights(listOfWeightsToUpdate);
  }

  bool segmentUseWeights() {
    List<EnrollmentMovement> movementsStoreWeights = [];
    widget.enrollmentMovements.forEach((movement) {
      if (movement.storeWeight) {
        movementsStoreWeights.add(movement);
      }
    });
    return movementsStoreWeights.isNotEmpty;
  }

  bool segmentHasWeightRecommendations() {
    List<EnrollmentMovement> movementsWithWeightRecommendation = [];
    widget.enrollmentMovements.forEach((movement) {
      if (movement.storeWeight && (movement.percentOfMaxWeight != null && movement.percentOfMaxWeight > 0)) {
        movementsWithWeightRecommendation.add(movement);
      }
    });
    return movementsWithWeightRecommendation.isNotEmpty;
  }

  int getMaxWeightForMovement(MovementSubmodel movement) {
    int maxWeightRecord = 0;
    if (widget.maxWeightRecords != null && widget.maxWeightRecords.isNotEmpty) {
      if (widget.maxWeightRecords.where((maxWeightRecord) => maxWeightRecord.id == movement.id).isNotEmpty) {
        maxWeightRecord = widget.maxWeightRecords.firstWhere((maxWeightRecord) => maxWeightRecord.id == movement.id).weight;
      }
    }
    return maxWeightRecord;
  }
}
