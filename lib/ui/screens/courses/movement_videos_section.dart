import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/ui/screens/courses/class_segment_section.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MovementVideosSection extends StatefulWidget {
  final List<Movement> movements;
  final Function(BuildContext, Movement) onPressedMovement;

  MovementVideosSection({this.movements, this.onPressedMovement});

  @override
  _State createState() => _State();
}

class _State extends State<MovementVideosSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/courses/gray_background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(children: [
          Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Image.asset(
                'assets/courses/horizontal_vector.png',
                scale: 3,
              )),
          // Container(
          //     height: 448,
          //     child: SingleChildScrollView(
          //         scrollDirection: Axis.horizontal,
          //         child: MovementItemBubbles(
          //             onPressed: widget.onPressedMovement,
          //             content: widget.movements,
          //             width: ScreenUtils.width(context) / 1)))
        ]));
  }
}
