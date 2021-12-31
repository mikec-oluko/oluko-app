import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileChallengesPage extends StatefulWidget {
  ProfileChallengesPage();
  @override
  _ProfileChallengesPageState createState() => _ProfileChallengesPageState();
}

class _ProfileChallengesPageState extends State<ProfileChallengesPage> {
  List<Challenge> challenges;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, state) {
        if (state is GetChallengeSuccess) {
          challenges = state.challenges;
        }
        return Scaffold(
          appBar: OlukoAppBar(
            title: ProfileViewConstants.profileChallengesPageTitle,
            showSearchBar: false,
          ),
          body: Container(
            color: OlukoColors.black,
            child: Container(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            OlukoLocalizations.of(context).find('upcomingChallenges'),
                            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                          ),
                        ),
                        Row(children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            child: ListView(
                              padding: const EdgeInsets.all(0),
                              scrollDirection: Axis.horizontal,
                              children: buildListOfChallenges(challenges),
                            ),
                          )
                        ]),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            OlukoLocalizations.get(context, 'all'),
                            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                          ),
                          GridView.count(
                            childAspectRatio: 0.5,
                            shrinkWrap: true,
                            primary: false,
                            padding: const EdgeInsets.all(0),
                            crossAxisCount: 4,
                            children: buildListOfChallenges(challenges),
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

  List<Widget> buildListOfChallenges(List<Challenge> challenges) {
    List<Widget> contentToReturn = [];
    challenges.forEach((challenge) {
      contentToReturn.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: ChallengesCard(
          challenge: challenge,
        ),
      ));
    });
    return contentToReturn;
  }
}
