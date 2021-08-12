import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ClassMovementSection extends StatefulWidget {
  final Class classObj;
  final List<Movement> movements;
  final Function(BuildContext, Movement) onPressedMovement;

  ClassMovementSection({
    this.classObj,
    this.onPressedMovement,
    this.movements,
  });

  @override
  _State createState() => _State();
}

class _State extends State<ClassMovementSection> {
  List<Movement> _movementsToShow = [];

  @override
  void initState() {
    super.initState();
    _movementsToShow = ClassService.getClassSegmentMovements(
        ClassService.getClassMovements(widget.classObj), widget.movements);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Divider(
        color: OlukoColors.grayColor,
        height: 50,
      ),
      Row(children: [
        Text(
          OlukoLocalizations.of(context).find('movesInThisClass'),
          style: OlukoFonts.olukoBigFont(
              custoFontWeight: FontWeight.w500,
              customColor: OlukoColors.grayColor),
        ),
        Expanded(child: SizedBox()),
        Text(
          OlukoLocalizations.of(context).find('viewDetails'),
          style: OlukoFonts.olukoBigFont(
              custoFontWeight: FontWeight.w500,
              customColor: OlukoColors.primary),
        )
      ]),
      buildMovementBubbles(),
    ]);
  }

  Widget buildMovementBubbles() {
    return Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: 

        MovementItemBubbles(
            //scrollable: false,
            onPressed: widget.onPressedMovement,
            content: _movementsToShow,
            width: ScreenUtils.width(context) / 1)
        );
  }
}
