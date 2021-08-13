import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/ui/components/challenge_card.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ClassSegmentSection extends StatefulWidget {
  final SegmentSubmodel segmentSubmodel;
  final List<Movement> movements;
  final bool showTopDivider;
  final Function(BuildContext, Movement) onPressedMovement;

  ClassSegmentSection(
      {this.movements,
      this.onPressedMovement,
      this.segmentSubmodel,
      this.showTopDivider = true});

  @override
  _State createState() => _State();
}

class _State extends State<ClassSegmentSection> {
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
            widget.showTopDivider
                ? Divider(
                    color: OlukoColors.grayColor,
                    height: 50,
                  )
                : SizedBox(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                widget.segmentSubmodel.name,
                style: OlukoFonts.olukoBigFont(
                    custoFontWeight: FontWeight.w500,
                    customColor: OlukoColors.grayColor),
              ),
            ),
            widget.segmentSubmodel.challengeImage != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 35.0),
                    child: ChallengeCard(
                        image: widget.segmentSubmodel.challengeImage))
                : SizedBox(),
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
