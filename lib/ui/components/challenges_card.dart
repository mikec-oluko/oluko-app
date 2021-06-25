import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ChallengesCard extends StatefulWidget {
  final Challenge challenge;

  ChallengesCard(this.challenge);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ChallengesCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TitleBody(ProfileViewConstants.profileUpcomingChallengesTitle),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Text(
                    ProfileViewConstants.profileOwnProfileViewAll,
                    style: TextStyle(color: OlukoColors.primary),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.challenge.imageCover),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IntrinsicHeight(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 120,
                      color: Colors.grey[850],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TitleBody(widget.challenge.title),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              widget.challenge.type,
                              style: TextStyle(
                                  fontSize: 14, color: OlukoColors.grayColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10)
                                .copyWith(top: 5),
                            child: Text(
                              widget.challenge.subtitle,
                              style: TextStyle(
                                  fontSize: 18, color: OlukoColors.grayColor),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: OlukoColors.primary,
                      radius: 30,
                      child:
                          IconButton(icon: Icon(Icons.star), onPressed: () {}),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
