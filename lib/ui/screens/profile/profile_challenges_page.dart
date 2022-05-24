import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_completed_before_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/models/user_response.dart';

class ProfileChallengesPage extends StatefulWidget {
  ProfileChallengesPage({this.challengeSegments, this.isCurrentUser, this.userRequested});
  final List<Widget> challengeSegments;
  final bool isCurrentUser;
  final UserResponse userRequested;
  @override
  _ProfileChallengesPageState createState() => _ProfileChallengesPageState();
}

class _ProfileChallengesPageState extends State<ProfileChallengesPage> {
  List<Challenge> challenges;
  List<Widget> challengesCards = [];
  @override
  void initState() {
    challengesCards = widget.challengeSegments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengeStreamBloc, ChallengeStreamState>(
      builder: (context, state) {
        if (state is GetChallengeStreamSuccess) {
          challenges = state.challenges;
        }
        return Scaffold(
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
                            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 3.5,
                          child: ListView(
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
                      height: MediaQuery.of(context).size.height / 2.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            OlukoLocalizations.get(context, 'all'),
                            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                          ),
                          Expanded(
                            child: BlocBuilder<ChallengeCompletedBeforeBloc, ChallengeCompletedBeforeState>(
                              builder: (BuildContext context, state) {
                                if (state is ChallengeListSuccess) {
                                  challengesCards = state.challenges;
                                }
                                return GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55),
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
        );
      },
    );
  }

  List<Widget> buildListOfChallenges(List<ChallengeNavigation> listOfChallenges) {
    List<Widget> contentToReturn = [];
    listOfChallenges.forEach((challenge) async {
      bool isChallengeCompleted = await BlocProvider.of<ChallengeCompletedBeforeBloc>(context)
          .checkChallengeWasCompleted(segmentId: challenge.segmentId, userId: challenge.enrolledCourse.userId);
      setState(() {
        contentToReturn.add(ChallengesCard(
          segmentChallenge: challenge,
          navigateToSegment: widget.isCurrentUser,
          customValueForChallenge: isChallengeCompleted,
          useAudio: !widget.isCurrentUser,
          userRequested: widget.userRequested,
        ));
      });
    });
    return contentToReturn;
  }
}
