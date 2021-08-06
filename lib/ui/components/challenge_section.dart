import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';

class ChallengeSection extends StatefulWidget {
  final List<SegmentSubmodel> challenges;

  ChallengeSection({this.challenges});

  @override
  _State createState() => _State();
}

class _State extends State<ChallengeSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: OlukoColors.grayColor,
              height: 50,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: getChallengesCards()),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getChallengesCards() {
    List<Widget> challengeCards = [];
    widget.challenges.forEach((challenge) {
      challengeCards.add(
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              child: Image.network(
                challenge.challengeImage,
                height: 115,
                width: 80,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
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
