import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MovementVideosSection extends StatefulWidget {
  final List<Movement> movements;
  final Segment segment;
  final Function(BuildContext, Movement) onPressedMovement;
  final Widget action;

  MovementVideosSection(
      {this.segment, this.movements, this.onPressedMovement, this.action});

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
        padding: EdgeInsets.only(left: 18),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/courses/gray_background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(children: [
          SizedBox(height: 15),
          Row(children: [
            //TODO: update text translation
            Text("Movement Videos",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
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
                      onPressed: widget.onPressedMovement,
                      content: segmentMovements,
                      width: ScreenUtils.width(context) / 1))),
          Image.asset(
            'assets/courses/horizontal_vector.png',
            scale: 2,
          )
        ]));
  }

  getSegmentMovements() {
    List<String> movementIds = [];
    List<Movement> movements = [];
    widget.segment.movements.forEach((MovementSubmodel movement) {
      movementIds.add(movement.id);
    });
    widget.movements.forEach((movement) {
      if (movementIds.contains(movement.id)) {
        movements.add(movement);
      }
    });
    return movements;
  }
}
