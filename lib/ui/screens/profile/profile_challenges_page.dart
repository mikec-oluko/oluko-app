import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_completed_before_bloc.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/screens/profile/challenge_courses_panel_content.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileChallengesPage extends StatefulWidget {
  ProfileChallengesPage(
      {this.challengesCardsState, this.isCurrentUser, this.userRequested, this.isCompletedChallenges = false, this.isUpcomingChallenge = false});
  final bool isCurrentUser;
  final UserResponse userRequested;
  final UniqueChallengesSuccess challengesCardsState;
  final bool isUpcomingChallenge;
  final bool isCompletedChallenges;

  @override
  _ProfileChallengesPageState createState() => _ProfileChallengesPageState();
}

class _ProfileChallengesPageState extends State<ProfileChallengesPage> {
  List<Challenge> challenges;
  PanelController _coursesPanelController = PanelController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isCompletedChallenges
        ? bodyByState()
        : widget.isUpcomingChallenge
            ? bodyByState()
            : _body(buildChallengeCards(widget.challengesCardsState));
  }

  Widget bodyByState() {
    return SlidingUpPanel(
      isDraggable: true,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      color: OlukoColors.black,
      minHeight: 0,
      maxHeight: (ScreenUtils.height(context) / 4) * 3,
      controller: _coursesPanelController,
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      panel: ChallengeCoursesPanelContent(panelController: _coursesPanelController),
      body: Scaffold(
        backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        appBar: OlukoAppBar(
          showBackButton: true,
          showTitle: true,
          title: widget.isCompletedChallenges
              ? OlukoLocalizations.get(context, 'completedChallenges')
              : widget.isUpcomingChallenge
                  ? OlukoLocalizations.get(context, 'upcomingChallenges')
                  : ProfileViewConstants.profileChallengesPageTitle,
          showSearchBar: false,
        ),
        body: Container(
            color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: widget.isCurrentUser ? 0.58 : 0.5),
                itemCount: getChallengeByType().length,
                itemBuilder: (context, index) => getChallengeByType()[index],
              ),
            )),
      ),
    );
  }

  Widget _body(List<Widget> challengesCards) {
    return BlocBuilder<ChallengeStreamBloc, ChallengeStreamState>(
      builder: (context, state) {
        if (state is GetChallengeStreamSuccess) {
          challenges = state.challenges;
        }
        return SlidingUpPanel(
            isDraggable: true,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            color: OlukoColors.black,
            minHeight: 0,
            maxHeight: (ScreenUtils.height(context) / 4) * 3,
            controller: _coursesPanelController,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            panel: ChallengeCoursesPanelContent(panelController: _coursesPanelController),
            body: Scaffold(
              backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
              appBar: OlukoAppBar(
                showBackButton: true,
                showTitle: true,
                title: ProfileViewConstants.profileChallengesPageTitle,
                showSearchBar: false,
              ),
              body: Container(
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                OlukoLocalizations.of(context).find('upcomingChallenges'),
                                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: widget.isCurrentUser ? MediaQuery.of(context).size.height / 4 : MediaQuery.of(context).size.height / 3.8,
                              child: ListView(
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: false,
                                padding: const EdgeInsets.all(0),
                                scrollDirection: Axis.horizontal,
                                children: challengesCards.take(3).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 2.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                OlukoLocalizations.get(context, 'all'),
                                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                              ),
                              Expanded(
                                child: BlocBuilder<ChallengeCompletedBeforeBloc, ChallengeCompletedBeforeState>(
                                  builder: (BuildContext context, state) {
                                    if (state is ChallengeListSuccess) {
                                      challengesCards = state.challenges;
                                    }
                                    return GridView.builder(
                                      padding: EdgeInsets.zero,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: widget.isCurrentUser ? 0.58 : 0.5),
                                      itemCount: challengesCards.length,
                                      itemBuilder: (context, index) => challengesCards[index],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  List<Widget> buildChallengeCards(UniqueChallengesSuccess state) {
    List<Widget> challengeList = [];
    for (String id in state.challengeMap.keys) {
      challengeList.add(ChallengesCard(
          panelController: _coursesPanelController,
          challengeNavigations: state.challengeMap[id],
          userRequested: !widget.isCurrentUser ? widget.userRequested : null,
          useAudio: !widget.isCurrentUser,
          segmentChallenge: state.challengeMap[id][0],
          navigateToSegment: widget.isCurrentUser,
          audioIcon: !widget.isCurrentUser,
          customValueForChallenge: state.lockedChallenges[id]));
    }
    ;
    return challengeList;
  }

  ChallengesCard _buildChallengeCardByState(String id) {
    return ChallengesCard(
        panelController: _coursesPanelController,
        challengeNavigations: widget.challengesCardsState.challengeMap[id],
        userRequested: !widget.isCurrentUser ? widget.userRequested : null,
        useAudio: !widget.isCurrentUser,
        segmentChallenge: widget.challengesCardsState.challengeMap[id][0],
        navigateToSegment: widget.isCurrentUser,
        audioIcon: !widget.isCurrentUser,
        customValueForChallenge: widget.challengesCardsState.lockedChallenges[id]);
  }

  List<Widget> getChallengeByType() {
    List<String> unlockedChallengesListOfIds = [];
    List<String> lockedChallengesListOfIds = [];
    List<Widget> _lockedChallenges = [];
    List<Widget> _unlockedChallenges = [];
    List<List<Widget>> challengeList = [];
    widget.challengesCardsState.lockedChallenges.forEach((key, value) {
      if (value) {
        unlockedChallengesListOfIds.add(key);
      } else {
        lockedChallengesListOfIds.add(key);
      }
    });

    for (String id in widget.challengesCardsState.challengeMap.keys) {
      if (unlockedChallengesListOfIds.contains(id)) {
        _unlockedChallenges.add(_buildChallengeCardByState(id));
      } else {
        _lockedChallenges.add(_buildChallengeCardByState(id));
      }
    }
    return widget.isCompletedChallenges
        ? _unlockedChallenges
        : widget.isUpcomingChallenge
            ? _lockedChallenges
            : [];
  }
}
