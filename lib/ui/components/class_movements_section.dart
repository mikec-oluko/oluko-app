import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/screens/courses/audio_dialog_content.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ClassMovementSection extends StatefulWidget {
  final Class classObj;
  final List<Movement> movements;
  final Function(BuildContext, Movement) onPressedMovement;
  final PanelController panelController;

  ClassMovementSection({this.classObj, this.onPressedMovement, this.movements, this.panelController});

  @override
  _State createState() => _State();
}

class _State extends State<ClassMovementSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       if (!OlukoNeumorphism.isNeumorphismDesign)
        const Divider(
          color: OlukoColors.grayColor,
          height: 50,
        ),
      Padding(
        padding: const EdgeInsets.only(top:20.0),
        child: Row(children: [
          Text(
            OlukoLocalizations.get(context, 'movesInThisClass'),
            style: OlukoNeumorphism.isNeumorphismDesign
                ? OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.white)
                : OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
          ),
          Expanded(child: SizedBox()),
          GestureDetector(
              onTap: () => widget.panelController.open(),
              child: SizedBox(
                width: 85,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    OlukoLocalizations.get(context, 'viewDetails'),
                    style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.primary),
                  ),
                ),
              ))
        ]),
      ),
      buildMovementBubbles(),
    ]);
  }

  Widget buildMovementBubbles() {
    return Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: MovementItemBubbles(
            showAsGrid: true, onPressed: widget.onPressedMovement, content: widget.movements, width: ScreenUtils.width(context) / 1));
  }
}
