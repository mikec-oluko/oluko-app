import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ChallengesCard extends StatefulWidget {
  final ChallengeNavigation segmentChallenge;
  final String routeToGo;
  final UserResponse userRequested;
  final bool navigateToSegment;
  final bool useAudio;
  final bool audioIcon;
  final bool customValueForChallenge;

  ChallengesCard(
      {this.routeToGo,
      this.segmentChallenge,
      this.userRequested,
      this.useAudio = true,
      this.navigateToSegment = false,
      this.customValueForChallenge = false,
      this.audioIcon = true});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ChallengesCard> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  Widget challengeCardWidget = const SizedBox.shrink();
  final Widget _cardSpacer = const SizedBox(height: 10);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: _challengeCard(context),
    );
    ;
  }

  Widget _challengeCard(BuildContext context) =>
      widget.customValueForChallenge ? _unlockedCardByCustomValue(context) : _unlockedCardByPreviousSegment(context);

  Column _unlockedCardByPreviousSegment(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _cardSpacer,
      if (widget.segmentChallenge.previousSegmentFinish) _unlockedCard(context) else _lockedCard(context),
      if (needAudioComponent) _audioElementForChallengeCard(context)
    ]);
  }

  Column _unlockedCardByCustomValue(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_cardSpacer, _unlockedCard(context), if (needAudioComponent) _audioElementForChallengeCard(context)]);
  }

  Row _audioElementForChallengeCard(BuildContext context) {
    return Row(
      children: [
        if (needAudioComponent)
          Padding(
              padding: const EdgeInsets.only(top: 13),
              child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.userChallengeDetail],
                      arguments: {'challenge': widget.segmentChallenge.challengeForAudio, 'userRequested': widget.userRequested}),
                  child: Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      'assets/courses/green_circle.png',
                      scale: 7,
                    ),
                    const Icon(Icons.mic, size: 20, color: OlukoColors.black)
                  ])))
        else
          const SizedBox.shrink(),
        if (needAudioComponent)
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: SizedBox(
                width: 75,
                child: Text(
                  '${OlukoLocalizations.get(context, 'saveFor')}${widget.userRequested.firstName}',
                  style: OlukoFonts.olukoSmallFont(),
                )),
          )
      ],
    );
  }

  bool get needAudioComponent => widget.useAudio && widget.audioIcon;

  Widget _lockedCard(BuildContext context) {
    return GestureDetector(
      onTap: !widget.useAudio && widget.navigateToSegment
          ? () => Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
                'segmentIndex': widget.segmentChallenge.segmentIndex,
                'classIndex': widget.segmentChallenge.classIndex,
                'courseEnrollment': widget.segmentChallenge.enrolledCourse,
                'courseIndex': widget.segmentChallenge.courseIndex,
                'fromChallenge': true
              })
          : () {},
      child: Container(
        decoration: const BoxDecoration(
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
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  color: OlukoColors.challengeLockedFilterColor,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.dstATop),
                      image: widget.segmentChallenge.challengeSegment.image != null
                          ? CachedNetworkImageProvider(widget.segmentChallenge.challengeSegment.image)
                          : defaultImage),
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

  Widget _unlockedCard(BuildContext context) {
    return GestureDetector(
      onTap: !widget.useAudio && widget.navigateToSegment
          ? () => Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
                'segmentIndex': widget.segmentChallenge.segmentIndex,
                'classIndex': widget.segmentChallenge.classIndex,
                'courseEnrollment': widget.segmentChallenge.enrolledCourse,
                'courseIndex': widget.segmentChallenge.courseIndex,
                'fromChallenge': true
              })
          : () {},
      child: Container(
        decoration: const BoxDecoration(
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
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: widget.segmentChallenge.challengeSegment.image != null
                          ? CachedNetworkImageProvider(widget.segmentChallenge.challengeSegment.image)
                          : defaultImage),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
