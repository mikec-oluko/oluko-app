import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class WeightTileForValue extends StatefulWidget {
  final List<WeightRecord> weightRecords;
  final bool useImperialSystem;
  final MovementSubmodel movement;
  final String segmentId;
  final bool showWeightRecommendation;
  final int percentageOfMaxWeight;
  final double maxWeightValue;
  const WeightTileForValue(
      {Key key,
      this.weightRecords,
      this.movement,
      this.percentageOfMaxWeight,
      this.maxWeightValue,
      this.segmentId,
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

  ListTile _movementTileWithWeightValue(MovementSubmodel movement) {
    return ListTile(
      trailing: getTrailingContent(movement),
      title: SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
      subtitle: canShowRecommendationSubtitle(movement)
          ? SegmentUtils.getTextWidget('(${movement.percentOfMaxWeight}${OlukoLocalizations.get(context, 'percentageOfMaxWeight')})', OlukoColors.grayColor)
          : const SizedBox.shrink(),
    );
  }

  bool canShowRecommendationSubtitle(MovementSubmodel movement) => movement.percentOfMaxWeight != null && movement.percentOfMaxWeight != 0;

  Container weightContainerForRecommendationOrRecent(MovementSubmodel movement) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: _getContainerColor(), borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: widget.showWeightRecommendation
            ? widget.percentageOfMaxWeight != null && widget.maxWeightValue != null
                ? _percentageOfMaxWeightForMovement(
                    userMaxWeight: MovementUtils.getMaxWeightByImperialSystemUse(maxWeight: widget.maxWeightValue, useImperialSystem: widget.useImperialSystem),
                    percentageOfMaxWeight: widget.percentageOfMaxWeight)
                : const SizedBox.shrink()
            : _userWeightRecord(movement),
      ),
    );
  }

  Widget _getAlertCircleWithTooltip() {
    const buttonIcon = '!';
    return Tooltip(
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
      if (widget.percentageOfMaxWeight != null && widget.maxWeightValue != null) {
        return weightContainerForRecommendationOrRecent(movement);
      } else {
        return _getAlertCircleWithTooltip();
      }
    } else {
      if (MovementUtils.getWeight(
              currentMovement: movement, segmentId: widget.segmentId, weightRecordsList: widget.weightRecords, useImperialSystem: widget.useImperialSystem) !=
          null) {
        return weightContainerForRecommendationOrRecent(movement);
      } else {
        return _getAlertCircleWithTooltip();
      }
    }
  }

  double getRecommendedWeight({int maxWeightValue, int percentageToUse}) => (maxWeightValue * percentageToUse) / 100;
}
