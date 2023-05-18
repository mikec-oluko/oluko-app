import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MovementVideosSection extends StatefulWidget {
  final Segment segment;
  final Function(BuildContext, MovementSubmodel) onPressedMovement;
  final Widget action;

  MovementVideosSection({this.segment, this.onPressedMovement, this.action});

  @override
  _State createState() => _State();
}

class _State extends State<MovementVideosSection> {
  List<MovementSubmodel> segmentMovements;

  @override
  void initState() {
    segmentMovements = getSegmentMovements();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: OlukoNeumorphism.isNeumorphismDesign
            ? BoxDecoration(
                color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)))
            : decorationImage(),
        child: Column(children: [
          SizedBox(height: OlukoNeumorphism.isNeumorphismDesign ? 5 : 15),
          !OlukoNeumorphism.isNeumorphismDesign
              ? SizedBox.shrink()
              : Center(
                  child: Container(
                    width: 50,
                    child: Image.asset('assets/courses/horizontal_vector.png', scale: 2, color: OlukoColors.grayColor),
                  ),
                ),
          OlukoNeumorphism.isNeumorphismDesign ? SizedBox(height: 25) : SizedBox.shrink(),
          Row(children: [
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(OlukoLocalizations.get(context, 'movementVideos'), style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 10),
            Image.asset(
              'assets/courses/person_running.png',
              scale: 4,
            ),
            Expanded(child: SizedBox()),
            widget.action
          ]),
          SizedBox(height: 6),
          Container(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: MovementItemBubbles(onPressed: widget.onPressedMovement, movements: segmentMovements, width: ScreenUtils.width(context) / 1))),
          OlukoNeumorphism.isNeumorphismDesign
              ? SizedBox.shrink()
              : Image.asset(
                  'assets/courses/horizontal_vector.png',
                  scale: 2,
                  color: Colors.red,
                )
        ]));
  }

  BoxDecoration decorationImage() {
    return const BoxDecoration(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [OlukoNeumorphismColors.initialGradientColorDark, OlukoNeumorphismColors.finalGradientColorDark],
      ),
    );
  }

  List<MovementSubmodel> getSegmentMovements() {
    List<MovementSubmodel> movementSubmodels = [];
    widget.segment.sections.forEach((section) {
      section.movements.forEach((MovementSubmodel movement) {
        if (!movement.isRestTime && movementSubmodels.where((savedMovement) => savedMovement.id == movement.id).toList().isEmpty) {
          movementSubmodels.add(movement);
        }
      });
    });
    return movementSubmodels;
  }
}
