import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_panel_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ChallengesCard extends StatefulWidget {
  final ChallengeNavigation segmentChallenge;
  final List<ChallengeNavigation> challengeNavigations;
  final PanelController panelController;
  final String routeToGo;
  final UserResponse userRequested;
  final bool navigateToSegment;
  final bool useAudio;
  final bool audioIcon;
  final bool customValueForChallenge;

  ChallengesCard(
      {this.routeToGo,
      this.segmentChallenge,
      this.panelController,
      this.challengeNavigations,
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

  Widget _challengeCard(BuildContext context) => widget.customValueForChallenge ? _unlockedCardByCustomValue(context) : _unlockedCardByPreviousSegment(context);

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
            padding: const EdgeInsets.only(top: 5),
            child: OlukoNeumorphicSecondaryButton(
              title: '',
              useBorder: true,
              isExpanded: false,
              thinPadding: true,
              onlyIcon: true,
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/courses/green_circle.png',
                    scale: 7,
                  ),
                  const Icon(Icons.mic, size: 20, color: OlukoColors.black)
                ],
              ),
              onPressed: () {
                if (widget.challengeNavigations.length == 1) {
                  navigateToAudioSegment(widget.challengeNavigations[0]);
                } else {
                  navigateToPanel(true);
                }
              },
            ),
          )
        else
          const SizedBox.shrink(),
        if (needAudioComponent)
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: SizedBox(
                width: ScreenUtils.width(context) * 0.17,
                child: Text(
                  '${OlukoLocalizations.get(context, 'saveFor')}${widget.userRequested.firstName}',
                  style: OlukoFonts.olukoSmallFont(),
                )),
          )
      ],
    );
  }

  bool get needAudioComponent => widget.useAudio && widget.audioIcon;

  void navigateToAudioSegment(ChallengeNavigation challengeNavigation) {
    Navigator.pushNamed(context, routeLabels[RouteEnum.userChallengeDetail],
        arguments: {'challenge': challengeNavigation.challengeForAudio, 'userRequested': widget.userRequested});
  }

  Widget _lockedCard(BuildContext context) {
    return GestureDetector(
      onTap: !widget.useAudio && widget.navigateToSegment
          ? () {
              navigate();
            }
          : () {},
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(end: Alignment.bottomRight, begin: Alignment.topLeft, colors: [Colors.red, OlukoColors.black, Colors.black, Colors.red]),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          color: OlukoColors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                maxWidthDiskCache: 100,
                maxHeightDiskCache: 100,
                imageUrl: widget.segmentChallenge.challengeSegment.image,
                imageBuilder: (context, imageProvider) => Container(
                  height: 160,
                  width: 115,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                    color: OlukoColors.challengeLockedFilterColor,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.dstATop),
                        image: widget.segmentChallenge.challengeSegment.image != null ? imageProvider : defaultImage),
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

  void navigate() {
    if (widget.challengeNavigations.length == 1) {
      navigateToSegmentDetail();
    } else {
      navigateToPanel();
    }
  }

  void navigateToPanel([bool navigateToAudio = false]) {
    if (widget.panelController != null) {
      widget.panelController.open();
    }
    BlocProvider.of<CoursePanelBloc>(context)
        .setPanelChallenges(widget.challengeNavigations, navigateToAudio ? (challenge) => navigateToAudioSegment(challenge) : null);
  }

  void navigateToSegmentDetail([ChallengeNavigation challengeNavigation]) {
    ChallengeNavigation challengeToUse;
    if (challengeNavigation != null) {
      challengeToUse = challengeNavigation;
    } else {
      challengeToUse = widget.segmentChallenge;
    }
    Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
      'segmentIndex': challengeToUse.segmentIndex,
      'classIndex': challengeToUse.classIndex,
      'courseEnrollment': challengeToUse.enrolledCourse,
      'courseIndex': challengeToUse.courseIndex,
      'fromChallenge': true
    });
  }

  Widget _unlockedCard(BuildContext context) {
    return GestureDetector(
      onTap: !widget.useAudio && widget.navigateToSegment
          ? () {
              navigate();
            }
          : () {},
      child: Container(
        decoration: const BoxDecoration(
          gradient:
              LinearGradient(end: Alignment.bottomRight, begin: Alignment.topLeft, colors: [Colors.red, OlukoColors.black, OlukoColors.black, Colors.red]),
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
                          ? CachedNetworkImageProvider(widget.segmentChallenge.challengeSegment.image, maxHeight: 160, maxWidth: 115)
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
