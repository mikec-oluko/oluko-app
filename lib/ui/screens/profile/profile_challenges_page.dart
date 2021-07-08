import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/ui/components/black_app_bar.dart';
import 'package:mvt_fitness/ui/components/challenges_card.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_constants.dart';

class ProfileChallengesPage extends StatefulWidget {
  @override
  _ProfileChallengesPageState createState() => _ProfileChallengesPageState();
}

class _ProfileChallengesPageState extends State<ProfileChallengesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileChallengesPageTitle,
        showSearchBar: false,
      ),
      body: Container(
        color: OlukoColors.black,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: ListView(
            children: buildListOfChallenges(challengeCollection),
          ),
        ),
      ),
    );
  }

  List<Widget> buildListOfChallenges(List<Challenge> challenges) => challenges
      .map((challenge) => ChallengesCard(
            challenge: challenge,
            needHeader: false,
          ))
      .toList();
}
