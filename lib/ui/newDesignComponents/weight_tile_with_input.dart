import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class WeightTileWithInput extends StatefulWidget {
  final MovementSubmodel movement;
  final EnrollmentMovement enrollmentMovement;
  final bool useImperialSystem;
  final TextEditingController currentTextEditingController;
  final Function(FocusNode focusNode, TextEditingController textEditingController) open;
  final GlobalKey<TooltipState> tooltipKey;

  const WeightTileWithInput(
      {Key key, this.movement, this.enrollmentMovement, this.open, this.currentTextEditingController, this.useImperialSystem = false, this.tooltipKey})
      : super(key: key);

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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [movementTitleAndWeightRecommendation(movement), movementInputAndPR(movement)],
      ),
    );
  }

  Row movementInputAndPR(MovementSubmodel movement) {
    return Row(
      children: [
        if (widget.enrollmentMovement.personalRecord) personalRecordComponent(),
        const SizedBox(
          width: 10,
        ),
        _inputComponent(movement.id),
      ],
    );
  }

  Column movementTitleAndWeightRecommendation(MovementSubmodel movement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: ScreenUtils.width(context) / 2.2,
          child: Text(SegmentUtils.getLabel(movement),
              maxLines: 2, style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor)),
        ),
        if (canShowRecommendationSubtitle(movement))
          SegmentUtils.getTextWidget('(${movement.percentOfMaxWeight}${OlukoLocalizations.get(context, 'percentageOfMaxWeight')})', OlukoColors.grayColor)
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Tooltip personalRecordComponent() {
    return Tooltip(
      showDuration: const Duration(seconds: 10),
      key: widget.tooltipKey,
      triggerMode: TooltipTriggerMode.manual,
      message: OlukoLocalizations.get(context, 'personalRecordRequired'),
      height: 50,
      decoration: const BoxDecoration(
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      child: Image.asset(
        'assets/icon/pr_star.png',
        scale: 4,
      ),
    );
  }

  bool canShowRecommendationSubtitle(MovementSubmodel movement) => movement.percentOfMaxWeight != null && movement.percentOfMaxWeight != 0;

  bool showSuffix = false;

  Container _inputComponent(String movementId) {
    return Container(
        decoration: const BoxDecoration(color: OlukoNeumorphismColors.appBackgroundColor, borderRadius: BorderRadius.all(Radius.circular(10))),
        width: 120,
        height: 40,
        child: Padding(padding: EdgeInsets.only(top: 3, left: 0), child: _textField()));
  }

  TextFormField _textField() {
    return TextFormField(
      focusNode: focusNode,
      autovalidateMode: AutovalidateMode.always,
      controller: widget.currentTextEditingController,
      maxLines: 1,
      showCursor: true,
      readOnly: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onTap: () {
        setState(() {
          showSuffix = true;
        });
        widget.open(focusNode, widget.currentTextEditingController);
      },
      onEditingComplete: () {},
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        color: OlukoColors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        focusColor: Colors.transparent,
        fillColor: Colors.transparent,
        hintText: OlukoLocalizations.get(context, 'addWeight'),
        hintStyle: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor),
        hintMaxLines: 1,
        border: InputBorder.none,
        suffixText: showSuffix
            ? widget.useImperialSystem
                ? OlukoLocalizations.get(context, 'lbs')
                : OlukoLocalizations.get(context, 'kgs')
            : null,
      ),
    );
  }
}
