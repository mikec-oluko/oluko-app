import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class LockedChallenge extends StatelessWidget {
  const LockedChallenge({
    Key key,
    this.challengeImage,
    this.context,
  }) : super(key: key);

  final String challengeImage;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
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
                  image: challengeImage != null ? new NetworkImage(challengeImage) : defaultImage,
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