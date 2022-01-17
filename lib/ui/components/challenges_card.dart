import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/recorder_view.dart';

class ChallengesCard extends StatefulWidget {
  final Challenge challenge;
  final String routeToGo;
  final UserResponse userRequested;
  final bool useAudio;

  ChallengesCard({this.challenge, this.routeToGo, this.userRequested, this.useAudio = true});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ChallengesCard> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 10),
      widget.challenge.completedAt != null
          ? unlockedCard(context)
          : lockedCardChallenge(widget: widget, defaultImage: defaultImage, context: context),
      if (widget.useAudio)
        Padding(
            padding: EdgeInsets.only(top: 13),
            child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.userChallengeDetail],
                    arguments: {'challenge': widget.challenge, 'userRequested': widget.userRequested}),
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/courses/green_circle.png',
                    scale: 6,
                  ),
                  Icon(Icons.mic, size: 23, color: OlukoColors.black)
                ])))
      else
        SizedBox.shrink()
    ]);
  }

  Widget unlockedCard(BuildContext context) {
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
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.challenge.image != null ? new NetworkImage(widget.challenge.image) : defaultImage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTopText() {
    String _defaultChallengeTitle = "In 2 weeks";
    return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 2, 0),
          child: Text(_defaultChallengeTitle, style: OlukoFonts.olukoSmallFont()),
        ));
  }
}

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
                  image: image!=null?new NetworkImage(image): widget.challenge.image != null ? new NetworkImage(widget.challenge.image) : defaultImage,
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
