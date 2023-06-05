import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class WeightTileWithInput extends StatefulWidget {
  final MovementSubmodel movement;
  final bool useImperialSystem;
  final Function(FocusNode focusNode, TextEditingController textEditingController) open;

  const WeightTileWithInput({Key key, this.movement, this.open, this.useImperialSystem = false}) : super(key: key);

  @override
  State<WeightTileWithInput> createState() => _WeightTileWithInputState();
}

class _WeightTileWithInputState extends State<WeightTileWithInput> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return _movementTileWithInput(widget.movement);
  }

  Padding _movementTileWithInput(MovementSubmodel movement) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentUtils.getTextWidget(SegmentUtils.getLabel(movement), OlukoColors.grayColor),
              if (canShowRecommendationSubtitle(movement))
                SegmentUtils.getTextWidget('(${movement.percentOfMaxWeight}${OlukoLocalizations.get(context, 'percentageOfMaxWeight')})', OlukoColors.grayColor)
              else
                const SizedBox.shrink(),
            ],
          ),
          _inputComponent(movement.id),
        ],
      ),
    );
  }

  bool canShowRecommendationSubtitle(MovementSubmodel movement) => movement.percentOfMaxWeight != null && movement.percentOfMaxWeight != 0;

  Container _inputComponent(String movementId) {
    return Container(
        decoration: const BoxDecoration(color: OlukoNeumorphismColors.appBackgroundColor, borderRadius: BorderRadius.all(Radius.circular(10))),
        width: 120,
        height: 40,
        child: TextFormField(
          focusNode: focusNode,
          controller: textEditingController,
          showCursor: true,
          readOnly: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onTap: () => widget.open(focusNode, textEditingController),
          onEditingComplete: () {},
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: OlukoColors.white,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
}
