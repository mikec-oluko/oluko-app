import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ChallengeSection extends StatefulWidget {
  final List<SegmentSubmodel> challenges;
  final bool addTitle;
  final bool addName;

  ChallengeSection({this.addName, this.challenges, this.addTitle = false});

  @override
  _State createState() => _State();
}

class _State extends State<ChallengeSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (OlukoNeumorphism.isNeumorphismDesign)
            const Padding(
                padding: EdgeInsets.all(20.0),
                child: OlukoNeumorphicDivider(
                  isFadeOut: true,
                ))
          else
            const Divider(
              color: OlukoColors.grayColor,
              height: 50,
            ),
          widget.addTitle
              ? OlukoNeumorphism.isNeumorphismDesign? Text(
                  buildTitle(),
                  style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.white),
                ):Text(
                  buildTitle(),
                  style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                )
              : SizedBox(),
          widget.addName != null && widget.addName
              ? Text(
                  widget.challenges[0].name,
                  style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                )
              : SizedBox(),
          SizedBox(height: widget.addTitle || widget.addName ? 20 : 0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: getChallengesCards()),
          )
        ],
      ),
    );
  }

  String buildTitle() {
    String title = "";
    title += widget.challenges.length.toString();
    title += " ";
    if (widget.challenges.length > 1) {
      title += OlukoLocalizations.get(context, 'challenges');
    } else {
      title += OlukoLocalizations.get(context, 'challenge');
    }
    return title;
  }

  List<Widget> getChallengesCards() {
   List<Widget> challengeCards = [];
    OlukoNeumorphism.isNeumorphismDesign? widget.challenges.forEach((challenge) {
      challengeCards.add(
        lockedCardChallenge(
          image: challenge.challengeImage,
    ),
      );
      challengeCards.add(SizedBox(width: 15));
    })

    :widget.challenges.forEach((challenge) {
      challengeCards.add(
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              child: Image.network(
                challenge.challengeImage,
                height: 140,
                width: 100,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
            ),
            Image.asset(
              'assets/courses/locked_challenge.png',
              width: 60,
              height: 60,
            )
          ],
        ),
      );
      challengeCards.add(SizedBox(width: 15));
    });
    return challengeCards;
  }
}
