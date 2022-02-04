import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import '../../routes.dart';

class CoachTabChallengeCard extends StatefulWidget {
  final CoachSegmentContent challenge;
  const CoachTabChallengeCard({this.challenge});

  @override
  _CoachTabChallengeCardState createState() => _CoachTabChallengeCardState();
}

class _CoachTabChallengeCardState extends State<CoachTabChallengeCard> {
  @override
  Widget build(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: coachChallengeCard(context),
              ),
              OlukoNeumorphicDivider(
                isForList: true,
                isFadeOut: true,
              )
            ],
          )
        : coachChallengeCard(context);
  }

  Widget coachChallengeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        routeLabels[RouteEnum.segmentDetail],
        arguments: {
          'segmentIndex': widget.challenge.indexSegment,
          'classIndex': widget.challenge.indexClass,
          'courseEnrollment': widget.challenge.courseEnrollment,
          'courseIndex': widget.challenge.indexCourse,
          'fromChallenge': true
        },
      ),
      child: Container(
        decoration: BoxDecoration(
            color: OlukoNeumorphism.isNeumorphismDesign
                ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark
                : OlukoColors.challengesGreyBackground,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        height: 100,
        width: ScreenUtils.width(context),
        child: Wrap(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(widget.challenge.classImage),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            return Text('Your error widget...');
                          },
                        ),
                        color: OlukoColors.warning,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
                    width: 60,
                    height: 90,
                  ),
                ),
                OlukoNeumorphism.isNeumorphismDesign
                    ? SizedBox(
                        width: 20,
                      )
                    : SizedBox.shrink(),
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
                                OlukoLocalizations.get(context, "challenge"),
                                style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                widget.challenge.segmentName,
                                overflow: TextOverflow.ellipsis,
                                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                OlukoLocalizations.of(context).find("challengeBy"),
                                style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                OlukoLocalizations.get(context, "coach"),
                                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
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
      ),
    );
  }
}
