import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/ui/components/challenge_card.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/ui/newDesignComponents/challenge_card_course_segment.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class ClassSegmentSection extends StatefulWidget {
  final Segment segment;
  final List<Movement> movements;
  final bool showTopDivider;
  final Function(BuildContext, Movement) onPressedMovement;

  ClassSegmentSection({this.movements, this.onPressedMovement, this.segment, this.showTopDivider = true});

  @override
  _State createState() => _State();
}

class _State extends State<ClassSegmentSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.segment == null) {
      return Container();
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: OlukoNeumorphism.isNeumorphismDesign
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      widget.segment?.name ?? "",
                      style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.white),
                    ),
                  ),
                  if (widget.segment != null && widget.segment.isChallenge)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 35.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          lockedCardChallenge(
                            image: widget.segment.image,
                          ),
                          SizedBox(width: 30.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: getRoundTitle(),
                          ),
                          getSegmentSummaryForNeumorphic(restTime: false, roundTitle: false, movements: widget.movements)
                        ]))
                  else
                    const SizedBox(),
                  if (widget.segment != null && !widget.segment.isChallenge)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getRoundTitle(),
                        Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: getSegmentSummaryForNeumorphic(restTime: false, roundTitle: false, movements: widget.movements)),
                      ],
                    )
                  else
                    const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: OlukoNeumorphicDivider(
                      isFadeOut: true,
                    ),
                  )
                ],
              )
            : Column(
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
                      widget.segment?.name ?? "",
                      style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.white),
                    ),
                  ),
                  (widget.segment != null && widget.segment.isChallenge)
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 35.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [ChallengeCard(image: widget.segment.image), SizedBox(width: 30.0), getSegmentSummary()]))
                      : SizedBox(),
                  Stack(
                    children: [
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: MovementItemBubbles(
                              onPressed: widget.onPressedMovement, content: widget.movements, width: ScreenUtils.width(context) / 1)),
                    ],
                  ),
                  (widget.segment != null && !widget.segment.isChallenge)
                      ? Padding(padding: const EdgeInsets.only(top: 10.0), child: getSegmentSummary())
                      : const SizedBox()
                ],
              ),
      ),
    );
  }

  Widget getSegmentSummary() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: SegmentUtils.getSegmentSummary(widget.segment, context, OlukoColors.grayColor));
  }

  Widget getSegmentSummaryForNeumorphic({bool restTime = true, bool roundTitle = true, List<Movement> movements}) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: SegmentUtils.getSegmentSummaryforNeumorphic(widget.segment, context, OlukoColors.grayColor,
            restTime: restTime, roundTitle: roundTitle, movements: movements));
  }

  Widget getRoundTitle() {
    return SegmentUtils.getRoundTitle(widget.segment,context, OlukoColors.grayColor );
  }
}
