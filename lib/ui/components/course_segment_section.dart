import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/newDesignComponents/locked_challenge.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_submodel_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'movement_item_bubbles.dart';

class CourseSegmentSection extends StatefulWidget {
  final SegmentSubmodel segment;
  final List<MovementSubmodel> movements;
  final Function() onPressedMovement;

  CourseSegmentSection({this.movements, this.onPressedMovement, this.segment});

  @override
  _State createState() => _State();
}

class _State extends State<CourseSegmentSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: OlukoNeumorphism.isNeumorphismDesign
            ? Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(const Radius.circular(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        widget.segment.name,
                        style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                      ),
                    ),
                    SegmentSubmodelUtils.getRoundTitle(widget.segment, context, OlukoColors.white),
                    SingleChildScrollView(
                        physics: OlukoNeumorphism.listViewPhysicsEffect,
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          if (widget.segment.isChallenge) LockedChallenge(challengeImage: widget.segment.image, context: context) else const SizedBox(),
                          MovementItemBubbles(
                            onPressed: widget.onPressedMovement,
                            movements: widget.movements,
                            width: ScreenUtils.width(context) / 1,
                            isSegmentSection: true,
                          )
                        ])),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: OlukoNeumorphicDivider(
                        isFadeOut: true,
                      ),
                    )
                  ],
                ),
              )
            : Container(
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
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        widget.segment.name,
                        style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                      ),
                    ),
                    SingleChildScrollView(
                        physics: OlukoNeumorphism.listViewPhysicsEffect,
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          widget.segment.isChallenge ? challengeCard() : SizedBox(),
                          MovementItemBubbles(onPressed: widget.onPressedMovement, movements: widget.movements, width: ScreenUtils.width(context) / 1)
                        ])),
                  ],
                ),
              ));
  }

  Widget challengeCard() {
    return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            (() {
              if (widget.segment.image != null) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  child: Image(
                    image: CachedNetworkImageProvider(widget.segment.image),
                    height: 140,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                return const SizedBox();
              }
            }()),
            Image.asset(
              'assets/courses/locked_challenge.png',
              width: 60,
              height: 60,
            )
          ],
        ));
  }
}
