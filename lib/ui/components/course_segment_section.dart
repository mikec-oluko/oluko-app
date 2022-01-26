import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'movement_item_bubbles.dart';

class CourseSegmentSection extends StatefulWidget {
  final SegmentSubmodel segment;
  final List<Movement> movements;
  final Function(BuildContext, Movement) onPressedMovement;

  CourseSegmentSection({this.movements, this.onPressedMovement, this.segment});

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
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                widget.segment.name,
                style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
              ),
            ),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  widget.segment.isChallenge ? challengeCard() : SizedBox(),
                  MovementItemBubbles(onPressed: widget.onPressedMovement, content: widget.movements, width: ScreenUtils.width(context) / 1)
                ])),
          ],
        ),
      ),
    );
  }

  Widget challengeCard() {
    return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            (() {
              if (widget.segment.challengeImage != null) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  child: Image.network(
                    widget.segment.challengeImage,
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
