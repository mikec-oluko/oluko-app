import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/recorder_view.dart';

class ChallengesCard extends StatefulWidget {
  final Challenge challenge;
  final ChallengeNavigation segmentChallenge;
  // final Function() routeToGo;
  final String routeToGo;
  final UserResponse userRequested;
  final bool navigateToSegment;
  final bool useAudio;
  final bool audioIcon;

  ChallengesCard(
      {this.challenge,
      this.routeToGo,
      this.segmentChallenge,
      this.userRequested,
      this.useAudio = true,
      this.navigateToSegment = false,
      this.audioIcon = true});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ChallengesCard> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 10),
      if (widget.navigateToSegment)
        widget.segmentChallenge.previousSegmentFinish ? unlockedCard(context) : lockedCard(context)
      else
        widget.challenge.completedAt != null ? unlockedCard(context) : lockedCard(context),
      if (widget.useAudio && widget.audioIcon)
        Padding(
            padding: EdgeInsets.only(top: 13),
            child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.userChallengeDetail], arguments: {
                      'challenge': widget.navigateToSegment ? widget.segmentChallenge.challengeForAudio : widget.challenge,
                      'userRequested': widget.userRequested
                    }),
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

  Widget lockedCard(BuildContext context) {
    return GestureDetector(
      onTap: widget.useAudio  && widget.navigateToSegment
          ? () => Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
                'segmentIndex': widget.segmentChallenge.segmentIndex,
                'classIndex': widget.segmentChallenge.classIndex,
                'courseEnrollment': widget.segmentChallenge.enrolledCourse,
                'courseIndex': widget.segmentChallenge.courseIndex,
                'fromChallenge': true
              })
          : () {},
      child: Container(
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
                    image: widget.navigateToSegment
                        ? widget.segmentChallenge.challengeSegment.challengeImage != null
                            ? CachedNetworkImageProvider(widget.segmentChallenge.challengeSegment.challengeImage)
                            : defaultImage
                        : widget.challenge.image != null
                            ? CachedNetworkImageProvider(widget.challenge.image)
                            : defaultImage,
                  ),
                ),
              ),
              Image.asset(
                'assets/courses/locked_challenge.png',
                width: 60,
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget unlockedCard(BuildContext context) {
    return GestureDetector(
      onTap: widget.useAudio  && widget.navigateToSegment
          ? () => Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
                'segmentIndex': widget.segmentChallenge.segmentIndex,
                'classIndex': widget.segmentChallenge.classIndex,
                'courseEnrollment': widget.segmentChallenge.enrolledCourse,
                'courseIndex': widget.segmentChallenge.courseIndex,
                'fromChallenge': true
              })
          : () {},
      child: Container(
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
                    image: widget.navigateToSegment
                        ? widget.segmentChallenge.challengeSegment.challengeImage != null
                            ? CachedNetworkImageProvider(widget.segmentChallenge.challengeSegment.challengeImage)
                            : defaultImage
                        : widget.challenge.image != null
                            ? CachedNetworkImageProvider(widget.challenge.image)
                            : defaultImage,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
