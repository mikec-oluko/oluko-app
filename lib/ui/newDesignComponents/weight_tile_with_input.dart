import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class WeightTileWithInput extends StatefulWidget {
  final MovementSubmodel movement;
  final bool useImperialSystem;
  final Function(String value) onChangeAction;
  final Function(String value) onSubmitAction;

  const WeightTileWithInput({Key key, this.movement, this.onChangeAction, this.onSubmitAction, this.useImperialSystem = false}) : super(key: key);

  @override
  State<WeightTileWithInput> createState() => _WeightTileWithInputState();
}

class _WeightTileWithInputState extends State<WeightTileWithInput> {
  @override
  Widget build(BuildContext context) {
    return _movementTileWithInput(widget.movement);
  }

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

  Container _inputComponent(String movementId) {
    return Container(
        decoration: const BoxDecoration(color: OlukoNeumorphismColors.appBackgroundColor, borderRadius: BorderRadius.all(Radius.circular(10))),
        width: 120,
        height: 40,
        child: TextFormField(
          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => widget.onChangeAction(value),
          onTap: () {},
          onFieldSubmitted: (value) => widget.onSubmitAction(value),
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
}
