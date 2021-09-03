import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';

class ChallengesCard extends StatefulWidget {
  final Challenge challenge;
  final String routeToGo;

  ChallengesCard({this.challenge, this.routeToGo});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ChallengesCard> {
  String _defaultChallengeTitle = "in 2 weeks";
  @override
  Widget build(BuildContext context) {
    return widget.challenge.completedAt != null
        ? unlockedCard(context)
        : lockedCard(context);
  }

  Stack lockedCard(BuildContext context) {
    const String iconToUse = 'assets/courses/locked_challenge.png';
    return Stack(
      alignment: Alignment.center,
      children: [
        // Align(
        //     alignment: Alignment.topRight,
        //     child: Padding(
        //       padding: const EdgeInsets.fromLTRB(15, 5, 2, 0),
        //       child: Text(_defaultChallengeTitle,
        //           style: OlukoFonts.olukoSmallFont()),
        //     )),
        Container(
          height: 115,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
            color: OlukoColors.challengeLockedFilterColor,
            image: new DecorationImage(
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.2), BlendMode.dstATop),
              image: new NetworkImage(widget.challenge.image),
            ),
          ),
        ),
        widget.challenge.completedAt == null
            ? Image.asset(
                iconToUse,
                width: 60,
                height: 60,
              )
            : SizedBox()
      ],
    );
  }

  Stack unlockedCard(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Align(
        //     alignment: Alignment.topRight,
        //     child: Padding(
        //       padding: const EdgeInsets.fromLTRB(15, 5, 2, 0),
        //       child: Text(_defaultChallengeTitle,
        //           style: OlukoFonts.olukoSmallFont()),
        //     )),
        Container(
          height: 115,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
            image: new DecorationImage(
              fit: BoxFit.cover,
              image: new NetworkImage(widget.challenge.image),
            ),
          ),
        ),
        SizedBox()
      ],
    );
  }
}
