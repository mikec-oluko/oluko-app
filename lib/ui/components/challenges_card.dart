import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/challenge/challenge_completed_before_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/recorder_view.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChallengesCard extends StatefulWidget {
  final ChallengeNavigation segmentChallenge;
  // final Function() routeToGo;
  final String routeToGo;
  final UserResponse userRequested;
  final bool navigateToSegment;
  final bool useAudio;
  final bool audioIcon;
  final bool checkUnlockedChallenge;
  final bool customValueForChallenge;

  ChallengesCard(
      {this.routeToGo,
      this.segmentChallenge,
      this.userRequested,
      this.useAudio = true,
      this.navigateToSegment = false,
      this.checkUnlockedChallenge = false,
      this.customValueForChallenge = false,
      this.audioIcon = true});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ChallengesCard> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  bool isChallengeFinishedBefore = false;
  Widget challengeCardWidget = SizedBox.shrink();
  Widget widgetContentToReturn = SizedBox.shrink();
  @override
  void initState() {
    widget.checkUnlockedChallenge
        ? BlocProvider.of<ChallengeCompletedBeforeBloc>(context)
            .completedChallengeBefore(segmentId: widget.segmentChallenge.segmentId, userId: widget.segmentChallenge.enrolledCourse.userId)
        : null;
    challengeCardWidget = OlukoCircularProgressIndicator();
    widgetContentToReturn = OlukoCircularProgressIndicator();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.checkUnlockedChallenge) {
      widgetContentToReturn = challengeCardWithBuilder();
    } else {
      if (widget.customValueForChallenge) {
        widgetContentToReturn = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 10),
          unlockedCard(context),
          if (widget.useAudio && widget.audioIcon) audioElementForChallengeCard(context)
        ]);
      } else {
        widgetContentToReturn = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 10),
          challengeCardWidget = widget.segmentChallenge.previousSegmentFinish ? unlockedCard(context) : lockedCard(context),
          if (widget.useAudio && widget.audioIcon) audioElementForChallengeCard(context)
        ]);
      }
    }
    return widgetContentToReturn;
  }

  BlocBuilder<ChallengeCompletedBeforeBloc, ChallengeCompletedBeforeState> challengeCardWithBuilder() {
    return BlocBuilder<ChallengeCompletedBeforeBloc, ChallengeCompletedBeforeState>(builder: (context, state) {
      if (state is ChallengeHistoricalResult) {
        isChallengeFinishedBefore = state.wasCompletedBefore;
        challengeCardWidget = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 10),
          if (isChallengeFinishedBefore)
            unlockedCard(context)
          else
            challengeCardWidget = widget.segmentChallenge.previousSegmentFinish ? unlockedCard(context) : lockedCard(context),
          if (widget.useAudio && widget.audioIcon) audioElementForChallengeCard(context)
        ]);
      }
      return challengeCardWidget;
    });
  }

  Row audioElementForChallengeCard(BuildContext context) {
    return Row(
      children: [
        if (widget.useAudio && widget.audioIcon)
          Padding(
              padding: EdgeInsets.only(top: 13),
              child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.userChallengeDetail],
                      arguments: {'challenge': widget.segmentChallenge.challengeForAudio, 'userRequested': widget.userRequested}),
                  child: Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      'assets/courses/green_circle.png',
                      scale: 7,
                    ),
                    Icon(Icons.mic, size: 20, color: OlukoColors.black)
                  ])))
        else
          SizedBox.shrink(),
        if (widget.useAudio && widget.audioIcon)
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

  Widget lockedCard(BuildContext context) {
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

  Widget unlockedCard(BuildContext context) {
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
