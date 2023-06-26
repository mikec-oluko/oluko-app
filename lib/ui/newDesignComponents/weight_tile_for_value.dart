import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class WeightTileForValue extends StatefulWidget {
  final List<WeightRecord> weightRecords;
  final bool useImperialSystem;
  final MovementSubmodel movement;
  final String segmentId;
  final bool showWeightRecommendation;
  final int percentageOfMaxWeight;
  final int sectionIndex;
  final double maxWeightValue;
  const WeightTileForValue(
      {Key key,
      this.weightRecords,
      this.movement,
      this.percentageOfMaxWeight,
      this.maxWeightValue,
      this.segmentId,
      this.sectionIndex,
      this.showWeightRecommendation = true,
      this.useImperialSystem = false})
      : super(key: key);

  @override
  State<WeightTileForValue> createState() => _WeightTileForValueState();
}

class _WeightTileForValueState extends State<WeightTileForValue> {
  @override
  Widget build(BuildContext context) {
    return _movementTileWithWeightValue(widget.movement);
  }

  Widget _movementTileWithWeightValue(MovementSubmodel movement) {
    return SizedBox(
      height: 50,
      child: ListTile(
        trailing: getTrailingContent(movement),
        title: SizedBox(
          width: ScreenUtils.width(context) / 2,
          child: Text(SegmentUtils.getLabel(movement),
              maxLines: 2, style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor)),
        ),
        subtitle: canShowRecommendationSubtitle(movement)
            ? SegmentUtils.getTextWidget('(${movement.percentOfMaxWeight}${OlukoLocalizations.get(context, 'percentageOfMaxWeight')})', OlukoColors.grayColor)
            : const SizedBox.shrink(),
      ),
    );
  }

  bool canShowRecommendationSubtitle(MovementSubmodel movement) => movement.percentOfMaxWeight != null && movement.percentOfMaxWeight != 0;

  Widget weightContainerForRecommendationOrRecent(MovementSubmodel movement) {
    if (widget.showWeightRecommendation) {
      if ((widget.percentageOfMaxWeight != null && widget.percentageOfMaxWeight != 0) && widget.maxWeightValue != null) {
        return recordContainer(_percentageOfMaxWeightForMovement(
            userMaxWeight: MovementUtils.getMaxWeightByImperialSystemUse(maxWeight: widget.maxWeightValue, useImperialSystem: widget.useImperialSystem),
            percentageOfMaxWeight: widget.percentageOfMaxWeight));
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return recordContainer(_userWeightRecord(movement));
    }
  }

  Container recordContainer(Widget childContent) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: _getContainerColor(), borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: childContent,
      ),
    );
  }

  Widget _getAlertCircleWithTooltip() {
    const buttonIcon = '!';
    return Tooltip(
      showDuration: const Duration(seconds: 20),
      triggerMode: TooltipTriggerMode.tap,
      richMessage: WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.ideographic,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 180, minWidth: 150),
            child: Center(
              child: Text(
                  widget.showWeightRecommendation
                      ? OlukoLocalizations.get(context, 'recommendationTooltipText')
                      : OlukoLocalizations.get(context, 'loggedWeightTooltipText'),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor)),
            ),
          )),
      textAlign: TextAlign.center,
      preferBelow: true,
      padding: const EdgeInsets.all(20),
      height: 100,
      decoration: const BoxDecoration(
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _getContainerColor(),
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        child: Center(child: Text(buttonIcon, style: OlukoFonts.olukoMediumFont(customColor: _getTextColor()))),
      ),
    );
  }

  Color _getContainerColor() => widget.showWeightRecommendation ? OlukoColors.primary : OlukoColors.primaryLight;

  Row _userWeightRecord(MovementSubmodel movement) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/courses/weight_icon.png',
          scale: 3,
          color: widget.showWeightRecommendation ? OlukoColors.white : OlukoNeumorphismColors.appBackgroundColor,
        ),
        Text(
          widget.weightRecords.isNotEmpty
              ? double.parse(MovementUtils.getWeight(
                      currentMovement: movement,
                      segmentId: widget.segmentId,
                      sectionIndex: widget.sectionIndex,
                      weightRecordsList: widget.weightRecords,
                      useImperialSystem: widget.useImperialSystem))
                  .round()
                  .toString()
              : '0',
          style: OlukoFonts.olukoMediumFont(customColor: _getTextColor()),
        ),
        const SizedBox(
          width: 2,
        ),
        Text(
          widget.useImperialSystem ? OlukoLocalizations.get(context, 'lbs') : OlukoLocalizations.get(context, 'kgs'),
          style: OlukoFonts.olukoMediumFont(customColor: _getTextColor()),
        )
      ],
    );
  }

  Color _getTextColor() => widget.showWeightRecommendation ? OlukoColors.white : OlukoNeumorphismColors.appBackgroundColor;

  Row _percentageOfMaxWeightForMovement({int userMaxWeight, int percentageOfMaxWeight}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/courses/weight_icon.png',
          scale: 3,
        ),
        Text(
          getRecommendedWeight(maxWeightValue: userMaxWeight, percentageToUse: percentageOfMaxWeight).round().toString(),
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
    );
  }

  Widget getTrailingContent(MovementSubmodel movement) {
    if (widget.showWeightRecommendation) {
      if (widget.percentageOfMaxWeight != null && (widget.maxWeightValue != null && widget.maxWeightValue != 0)) {
        return weightContainerForRecommendationOrRecent(movement);
      } else {
        return _getAlertCircleWithTooltip();
      }
    } else {
      if (MovementUtils.getWeight(
              currentMovement: movement,
              segmentId: widget.segmentId,
              sectionIndex: widget.sectionIndex,
              weightRecordsList: widget.weightRecords,
              useImperialSystem: widget.useImperialSystem) !=
          null) {
        return weightContainerForRecommendationOrRecent(movement);
      } else {
        return _getAlertCircleWithTooltip();
      }
    }
  }

  double getRecommendedWeight({int maxWeightValue, int percentageToUse}) => (maxWeightValue * percentageToUse) / 100;
}
