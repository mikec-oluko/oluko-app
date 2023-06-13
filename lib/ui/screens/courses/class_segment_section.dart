import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/ui/components/challenge_card.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class ClassSegmentSection extends StatefulWidget {
  final Segment segment;
  final List<Movement> movements;
  final List<MovementSubmodel> movementSubmodels;
  final bool showTopDivider;
  final Function(BuildContext, MovementSubmodel) onPressedMovement;
  final ChallengeNavigation challengeNavigation;

  ClassSegmentSection({this.movementSubmodels, this.movements, this.onPressedMovement, this.segment, this.showTopDivider = true, this.challengeNavigation});

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
          child: OlukoNeumorphism.isNeumorphismDesign ? neumorphicContent() : content()),
    );
  }

  Widget content() {
    return Column(
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
            style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.white),
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
                child: MovementItemBubbles(onPressed: widget.onPressedMovement, movements: widget.movementSubmodels, width: ScreenUtils.width(context) / 1)),
          ],
        ),
        (widget.segment != null && !widget.segment.isChallenge)
            ? Padding(padding: const EdgeInsets.only(top: 10.0), child: getSegmentSummary())
            : const SizedBox()
      ],
    );
  }

  Widget neumorphicContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        segmentTitle(),
        SizedBox(height: 20),
        segmentSection(),
        OlukoNeumorphicDivider(
          isFadeOut: true,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget challengeSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ChallengesCard(
          userRequested: null,
          useAudio: false,
          segmentChallenge: widget.challengeNavigation,
          navigateToSegment: true,
          audioIcon: false,
          customValueForChallenge: widget.challengeNavigation != null ? widget.challengeNavigation.previousSegmentFinish : false),
      const SizedBox(height: 25.0),
      getRoundTitle(),
      getNeumorphicSegmentSummary(restTime: false, roundTitle: false, movements: widget.movements),
      const SizedBox(width: 35.0),
    ]);
  }

  Widget notChallengeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getRoundTitle(),
        getNeumorphicSegmentSummary(restTime: false, roundTitle: false, movements: widget.movements),
      ],
    );
  }

  Widget segmentSection() {
    if (widget.segment != null) {
      if (widget.segment.isChallenge) {
        return challengeSection();
      } else {
        return notChallengeSection();
      }
    }
    return const SizedBox();
  }

  Widget segmentTitle() {
    return Text(
      widget.segment?.name ?? "",
      style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.white),
    );
  }

  Widget getSegmentSummary() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: SegmentUtils.getSegmentSummary(widget.segment, context, OlukoColors.grayColor));
  }

  Widget getNeumorphicSegmentSummary({bool restTime = true, bool roundTitle = true, List<Movement> movements}) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: SegmentUtils.getSegmentSummaryforNeumorphic(widget.segment, context, OlukoColors.grayColor,
            restTime: restTime, roundTitle: roundTitle, movements: movements));
  }

  Widget getRoundTitle() {
    if (widget.segment.rounds == null || widget.segment.rounds > 1) {
      return Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            SegmentUtils.getRoundTitle(widget.segment, context),
            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.bold),
          ));
    } else {
      return const SizedBox();
    }
  }
}
