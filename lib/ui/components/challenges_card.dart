import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ChallengesCard extends StatefulWidget {
  final ChallengeStatic challenge;
  final String routeToGo;
  final bool needHeader;

  ChallengesCard({this.challenge, this.routeToGo, this.needHeader = true});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ChallengesCard> {
  @override
  Widget build(BuildContext context) {
    return widget.challenge.isLocked
        ? lockedCard(context)
        : unlockedCard(context);
  }

  Container unlockedCard(BuildContext context) {
    const String iconToUse = 'assets/courses/course_trophy.png';

    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        children: [
          widget.needHeader
              ? buildCardHeaderWithLink(context)
              : Container(width: 0, height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    image: DecorationImage(
                      image: AssetImage(widget.challenge.imageCover),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5)),
                      color: Colors.grey[850],
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 120,
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
                          padding:
                              const EdgeInsets.only(left: 10).copyWith(top: 5),
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
                  top: 85,
                  right: 5,
                  child: TextButton(
                      onPressed: () {},
                      child: Image.asset(
                        iconToUse,
                        width: 70,
                        height: 70,
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container lockedCard(BuildContext context) {
    return Container(
      child: Column(
        children: [
          widget.needHeader
              ? buildCardHeaderWithLink(context)
              : Container(width: 0, height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.7), BlendMode.srcOver),
                      image: AssetImage(widget.challenge.imageCover),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5)),
                      color: OlukoColors.challengesGreyBackground,
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 120,
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
                          padding:
                              const EdgeInsets.only(left: 10).copyWith(top: 5),
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
                    top: 20,
                    right: MediaQuery.of(context).size.width / 3,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: OlukoColors.grayColorSemiTransparent,
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            OlukoLocalizations.of(context).find('yetToUnlock'),
                            style: OlukoFonts.olukoBigFont(
                                customColor: OlukoColors.grayColor),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Row buildCardHeaderWithLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TitleBody(ProfileViewConstants.profileUpcomingChallengesTitle),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, widget.routeToGo),
            child: Text(
              OlukoLocalizations.of(context).find('viewAll'),
              style: TextStyle(color: OlukoColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
