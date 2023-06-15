import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class UserChallengeSection extends StatefulWidget {
  final UserResponse userToDisplay;
  final bool isCurrentUser;
  final UniqueChallengesSuccess challengeState;
  final PanelController panelController;
  final bool defaultNavigation;
  final bool isForHome;

  const UserChallengeSection(
      {this.userToDisplay, this.isCurrentUser, this.challengeState, this.panelController, this.defaultNavigation = false, this.isForHome = false})
      : super();

  @override
  State<UserChallengeSection> createState() => _UserChallengeSectionState();
}

class _UserChallengeSectionState extends State<UserChallengeSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getCarouselSection(buildChallengeCards()[0], OlukoLocalizations.get(context, 'upcomingChallenges'),
            isUpcomingChallenges: widget.defaultNavigation ? false : true),
        if (buildChallengeCards()[1].isNotEmpty)
          getCarouselSection(buildChallengeCards()[1], OlukoLocalizations.get(context, 'completedChallenges'),
              isCompletedChallenges: widget.defaultNavigation ? false : true),
      ],
    );
  }

  Widget getCarouselSection(List<Widget> challengeList, String title, {bool isCompletedChallenges = false, bool isUpcomingChallenges = false}) {
    return CarouselSection(
        height: widget.isForHome ? ScreenUtils.height(context) / 4 : 266,
        width: MediaQuery.of(context).size.width,
        title: title,
        optionLabel: OlukoLocalizations.get(context, 'viewAll'),
        onOptionTap: () {
          if (widget.defaultNavigation) {
            if (widget.challengeState != null) {
              Navigator.pushNamed(context, routeLabels[RouteEnum.profileChallenges],
                  arguments: {'isCurrentUser': widget.isCurrentUser, 'userRequested': widget.userToDisplay, 'challengesCardsState': widget.challengeState});
            }
          }
          if (isCompletedChallenges) {
            Navigator.pushNamed(context, routeLabels[RouteEnum.profileChallenges], arguments: {
              'isCurrentUser': widget.isCurrentUser,
              'userRequested': widget.userToDisplay,
              'challengesCardsState': widget.challengeState,
              'isCompletedChallenges': true
            });
          }
          if (isUpcomingChallenges) {
            Navigator.pushNamed(context, routeLabels[RouteEnum.profileChallenges], arguments: {
              'isCurrentUser': widget.isCurrentUser,
              'userRequested': widget.userToDisplay,
              'challengesCardsState': widget.challengeState,
              'isUpcomingChallenge': true
            });
          }
        },
        children: challengeList.isNotEmpty ? challengeList : [const SizedBox.shrink()]);
  }

  List<List<Widget>> buildChallengeCards() {
    List<String> unlockedChallengesListOfIds = [];
    List<String> lockedChallengesListOfIds = [];
    List<Widget> _lockedChallenges = [];
    List<Widget> _unlockedChallenges = [];
    List<List<Widget>> challengeList = [];
    widget.challengeState.lockedChallenges.forEach((key, value) {
      if (value) {
        unlockedChallengesListOfIds.add(key);
      } else {
        lockedChallengesListOfIds.add(key);
      }
    });

    for (String id in widget.challengeState.challengeMap.keys) {
      if (unlockedChallengesListOfIds.contains(id)) {
        _unlockedChallenges.add(_buildChallengeCard(id));
      } else {
        _lockedChallenges.add(_buildChallengeCard(id));
      }
    }
    return challengeList = [_lockedChallenges, _unlockedChallenges];
  }

  ChallengesCard _buildChallengeCard(String id) {
    return ChallengesCard(
        panelController: widget.panelController,
        challengeNavigations: widget.challengeState.challengeMap[id],
        userRequested: !widget.isCurrentUser ? widget.userToDisplay : null,
        useAudio: !widget.isCurrentUser,
        segmentChallenge: widget.challengeState.challengeMap[id][0],
        navigateToSegment: widget.isCurrentUser,
        audioIcon: !widget.isCurrentUser,
        customValueForChallenge: widget.challengeState.lockedChallenges[id]);
  }
}
