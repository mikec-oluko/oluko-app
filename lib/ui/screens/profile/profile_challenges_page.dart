import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileChallengesPage extends StatefulWidget {
  ProfileChallengesPage({this.challengeSegments, this.isCurrentUser});
  final List<ChallengeNavigation> challengeSegments;
  final bool isCurrentUser;
  @override
  _ProfileChallengesPageState createState() => _ProfileChallengesPageState();
}

class _ProfileChallengesPageState extends State<ProfileChallengesPage> {
  List<Challenge> challenges;

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
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
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
                            height: MediaQuery.of(context).size.height / 3,
                            child: ListView(
                              padding: const EdgeInsets.all(0),
                              scrollDirection: Axis.horizontal,
                              children: buildListOfChallenges(widget.challengeSegments).take(3).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
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
                              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                            ),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.6),
                                itemCount: buildListOfChallenges(widget.challengeSegments).length,
                                itemBuilder: (context, index) => ChallengesCard(
                                  segmentChallenge: widget.challengeSegments[index],
                                  useAudio: false,
                                  navigateToSegment: widget.isCurrentUser,
                                ),
                              ),
                            ),
                          ],
                        ),
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
    listOfChallenges.forEach((challenge) {
      contentToReturn.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: ChallengesCard(
          segmentChallenge: challenge,
          useAudio: false,
          navigateToSegment: widget.isCurrentUser,
        ),
      ));
    });
    return contentToReturn;
  }
}
