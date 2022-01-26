import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';

class lockedCardChallenge extends StatelessWidget {
  const lockedCardChallenge({
    Key key,
    this.widget,
    this.defaultImage,
    this.context,
    this.image,
  }) : super(key: key);

  final ChallengesCard widget;
  final ImageProvider<Object> defaultImage;
  final BuildContext context;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            end: Alignment.bottomRight, begin: Alignment.topLeft, colors: [Colors.red, Colors.black, Colors.black, Colors.red]),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        color: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 160,
              width: 115,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                color: OlukoColors.challengeLockedFilterColor,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.dstATop),
                  image: image != null
                      ? new NetworkImage(image)
                      : widget.challenge.image != null
                          ? new NetworkImage(widget.challenge.image)
                          : defaultImage,
                ),
              ),
            ),
            Image.asset(
              'assets/courses/locked_challenge.png',
              width: 60,
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}
