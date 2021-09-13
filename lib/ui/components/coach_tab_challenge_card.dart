import 'package:flutter/cupertino.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachTabChallengeCard extends StatefulWidget {
  final Challenge challenge;
  const CoachTabChallengeCard({this.challenge});

  @override
  _CoachTabChallengeCardState createState() => _CoachTabChallengeCardState();
}

class _CoachTabChallengeCardState extends State<CoachTabChallengeCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: OlukoColors.challengesGreyBackground,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      height: 100,
      width: 150,
      child: Wrap(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.challenge.image),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          return Text('Your error widget...');
                        },
                      ),
                      color: OlukoColors.warning,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  width: 60,
                  height: 90,
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              OlukoLocalizations.of(context).find("challenge"),
                              style: OlukoFonts.olukoSmallFont(
                                  customColor: OlukoColors.grayColor,
                                  custoFontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              widget.challenge.challengeName,
                              overflow: TextOverflow.ellipsis,
                              style: OlukoFonts.olukoMediumFont(
                                  customColor: OlukoColors.white,
                                  custoFontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              OlukoLocalizations.of(context)
                                  .find("challengeBy"),
                              style: OlukoFonts.olukoSmallFont(
                                  customColor: OlukoColors.grayColor,
                                  custoFontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              OlukoLocalizations.of(context).find("coach"),
                              style: OlukoFonts.olukoMediumFont(
                                  customColor: OlukoColors.white,
                                  custoFontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
