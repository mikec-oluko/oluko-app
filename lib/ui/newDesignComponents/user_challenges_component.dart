import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class UserChallengeSection extends StatefulWidget {
  final UserResponse userToDisplay;
  final bool isCurrentUser;
  final UniqueChallengesSuccess challengeState;

  const UserChallengeSection({this.userToDisplay, this.isCurrentUser, this.challengeState}) : super();

  @override
  State<UserChallengeSection> createState() => _UserChallengeSectionState();
}

class _UserChallengeSectionState extends State<UserChallengeSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getCarouselSection(buildChallengeCards()[0], OlukoLocalizations.get(context, 'upcomingChallenges')),
        if (buildChallengeCards()[1].isNotEmpty) getCarouselSection(buildChallengeCards()[1], OlukoLocalizations.get(context, 'completedChallenges')),
      ],
    );
  }

  Widget getCarouselSection(List<Widget> challengeList, String title) {
    return CarouselSection(
        height: ScreenUtils.height(context) / 4,
        width: MediaQuery.of(context).size.width,
        title: title,
        optionLabel: OlukoLocalizations.get(context, 'viewAll'),
        onOptionTap: () {
          if (widget.challengeState != null) {
            Navigator.pushNamed(context, routeLabels[RouteEnum.profileChallenges],
                arguments: {'isCurrentUser': widget.isCurrentUser, 'userRequested': widget.userToDisplay, 'challengesCardsState': widget.challengeState});
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
        challengeNavigations: widget.challengeState.challengeMap[id],
        userRequested: !widget.isCurrentUser ? widget.userToDisplay : null,
        useAudio: !widget.isCurrentUser,
        segmentChallenge: widget.challengeState.challengeMap[id][0],
        navigateToSegment: widget.isCurrentUser,
        audioIcon: !widget.isCurrentUser,
        customValueForChallenge: widget.challengeState.lockedChallenges[id]);
  }
}
