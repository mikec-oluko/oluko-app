import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'movement_item_bubbles.dart';

class CourseSegmentSection extends StatefulWidget {
  final String segmentName;
  final List<Movement> movements;
  final Function(BuildContext, Movement) onPressedMovement;

  CourseSegmentSection(
      {this.movements, this.onPressedMovement, this.segmentName});

  @override
  _State createState() => _State();
}

class _State extends State<CourseSegmentSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: OlukoColors.grayColor,
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                widget.segmentName,
                style: OlukoFonts.olukoBigFont(
                    custoFontWeight: FontWeight.normal,
                    customColor: OlukoColors.grayColor),
              ),
            ),
            Stack(
              children: [
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: MovementItemBubbles(
                        onPressed: widget.onPressedMovement,
                        content: widget.movements,
                        width: ScreenUtils.width(context) / 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
