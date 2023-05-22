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
  final bool showWeightRecommendation;
  const WeightTileForValue({Key key, this.weightRecords, this.movement, this.showWeightRecommendation = true, this.useImperialSystem = false})
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
      trailing: MovementUtils.getWeight(currentMovement: movement, weightRecordsList: widget.weightRecords, useImperialSystem: widget.useImperialSystem) == null
          ? Container(
              color: Colors.red,
            )
          : Container(
              height: 40,
              decoration: BoxDecoration(color: _getContainerColor(), borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: widget.showWeightRecommendation
                    ? _percentageOfMaxWeightForMovement(
                        userMaxWeigth: MovementUtils.getMaxWeightByImperialSystemUse(maxWeight: 100, useImperialSystem: widget.useImperialSystem),
                        percentageOfMaxWeigth: 25)
                    : _userWeigthRecord(movement),
              ),
            ),
      title: SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
      subtitle: movement.percentOfMaxWeight != null
          ? SegmentUtils.getTextWidget('(${movement.percentOfMaxWeight} ${OlukoLocalizations.get(context, 'percentageOfMaxWeight')})', OlukoColors.grayColor)
          : const SizedBox.shrink(),
    );
  }

  Color _getContainerColor() => widget.showWeightRecommendation ? OlukoColors.primary : OlukoColors.primaryLight;

  Row _userWeigthRecord(MovementSubmodel movement) {
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
              ? double.parse(
                      MovementUtils.getWeight(currentMovement: movement, weightRecordsList: widget.weightRecords, useImperialSystem: widget.useImperialSystem))
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

  Row _percentageOfMaxWeightForMovement({int userMaxWeigth, int percentageOfMaxWeigth}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/courses/weight_icon.png',
          scale: 3,
        ),
        Text(
          getRecommendedWeight(maxWeigthValue: userMaxWeigth, percentageToUse: percentageOfMaxWeigth).round().toString(),
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

  double getRecommendedWeight({int maxWeigthValue, int percentageToUse}) => (maxWeigthValue * percentageToUse) / 100;
}
