import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class UserProfileProgress extends StatefulWidget {
  final String challengesCompleted;
  final String coursesCompleted;
  final String classesCompleted;

  const UserProfileProgress({this.challengesCompleted, this.coursesCompleted, this.classesCompleted}) : super();

  @override
  _UserProfileProgressState createState() => _UserProfileProgressState();
}

class _UserProfileProgressState extends State<UserProfileProgress> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: OlukoNeumorphism.isNeumorphismDesign ? buildUserNeumorphicStatistics() : buildUserStatistics(),
    );
  }

  IntrinsicHeight buildUserNeumorphicStatistics() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileNeumorphicAccomplishments(
                      achievementTitleKey: 'challengesCompleted', achievementValue: widget.challengesCompleted, color: OlukoColors.white),
                  profileNeumorphicAccomplishments(
                      achievementTitleKey: 'classesCompleted', achievementValue: widget.classesCompleted, color: OlukoColors.white),
                ],
              ),
            ),
          ),
          Align(child: profileVerticalDivider(isNeumorphic: true)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20).copyWith(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileNeumorphicAccomplishments(
                      achievementTitleKey: 'coursesCompleted', achievementValue: widget.coursesCompleted, color: OlukoColors.white),
                  const SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Column buildUserStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileAccomplishments(
                  achievementTitleKey: 'challengesCompleted', achievementValue: widget.challengesCompleted, color: OlukoColors.primary),
              profileVerticalDivider(),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              profileAccomplishments(
                  achievementTitleKey: 'coursesCompleted', achievementValue: widget.coursesCompleted, color: OlukoColors.primary),
              profileVerticalDivider(),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              profileAccomplishments(
                  achievementTitleKey: 'classesCompleted', achievementValue: widget.classesCompleted, color: OlukoColors.white),
            ],
          ),
        )
      ],
    );
  }

  VerticalDivider profileVerticalDivider({bool isNeumorphic = false}) {
    return VerticalDivider(
      color: isNeumorphic ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.white,
      thickness: 1,
      indent: isNeumorphic ? 5 : 20,
      endIndent: 6,
      width: 1,
    );
  }

  Widget profileAccomplishments({String achievementTitleKey, String achievementValue, Color color}) {
    const double _textContainerWidth = 88;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              achievementValue,
              style: OlukoFonts.olukoBigFont(customColor: color, custoFontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Column(
          children: [
            SizedBox(
              width: _textContainerWidth,
              child: Text(OlukoLocalizations.get(context, achievementTitleKey),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300)),
            ),
          ],
        ),
      ],
    );
  }

  Widget profileNeumorphicAccomplishments({String achievementTitleKey, String achievementValue, Color color}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievementValue,
            style: OlukoFonts.olukoSuperBigFont(customColor: color, custoFontWeight: FontWeight.w500),
          ),
          const SizedBox(
            width: 5,
          ),
          if (ScreenUtils.height(context) < 700)
            Expanded(
                child: Text(
              OlukoLocalizations.get(context, achievementTitleKey),
              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w400),
            ))
          else
            Container(
              width: 70,
              child: Text(
                OlukoLocalizations.get(context, achievementTitleKey),
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w400),
              ),
            )
        ],
      ),
    );
  }
}
