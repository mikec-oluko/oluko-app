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
  final List<Movement> movements;
  final Segment segment;
  final Function(BuildContext, Movement) onPressedMovement;
  final Widget action;

  MovementVideosSection({this.segment, this.movements, this.onPressedMovement, this.action});

  @override
  _State createState() => _State();
}

class _State extends State<MovementVideosSection> {
  List<Movement> segmentMovements;

  @override
  void initState() {
    segmentMovements = getSegmentMovements();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // padding: EdgeInsets.only(left: 18),
        decoration: OlukoNeumorphism.isNeumorphismDesign
            ? BoxDecoration(
                color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)))
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
          OlukoNeumorphism.isNeumorphismDesign ? SizedBox(height: 10) : SizedBox.shrink(),
          Row(children: [
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(OlukoLocalizations.get(context, 'movementVideos'),
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 10),
            Icon(Icons.directions_run, color: Colors.white, size: 30),
            Expanded(child: SizedBox()),
            widget.action
          ]),
          SizedBox(height: 6),
          Container(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: MovementItemBubbles(
                      onPressed: widget.onPressedMovement, content: segmentMovements, width: ScreenUtils.width(context) / 1))),
          OlukoNeumorphism.isNeumorphismDesign
              ? SizedBox.shrink()
              : Image.asset(
                  'assets/courses/horizontal_vector.png',
                  scale: 2,
                )
        ]));
  }

  BoxDecoration decorationImage() {
    return BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/courses/gray_background.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)));
  }

  List<Movement> getSegmentMovements() {
    List<String> movementIds = [];
    List<Movement> movements = [];
    widget.segment.sections.forEach((section) {
      section.movements.forEach((MovementSubmodel movement) {
        if (!movement.isRestTime) {
          movementIds.add(movement.id);
        }
      });
    });
    widget.movements.forEach((movement) {
      if (movementIds.contains(movement.id)) {
        movements.add(movement);
      }
    });
    return movements;
  }
}
