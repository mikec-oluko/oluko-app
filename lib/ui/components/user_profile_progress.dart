import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileNeumorphicAccomplishments(
                  achievementTitleKey: 'challengesCompleted', achievementValue: widget.challengesCompleted, color: OlukoColors.white),
              profileNeumorphicAccomplishments(
                  achievementTitleKey: 'classesCompleted', achievementValue: widget.classesCompleted, color: OlukoColors.white),
            ],
          ),
          profileVerticalDivider(isNeumorphic: true),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileNeumorphicAccomplishments(
                  achievementTitleKey: 'coursesCompleted', achievementValue: widget.coursesCompleted, color: OlukoColors.white),
              const SizedBox(
                height: 40,
              )
            ],
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
      indent: isNeumorphic ? 10 : 20,
      endIndent: 6,
      width: 1,
    );
  }

  Widget profileAccomplishments({String achievementTitleKey, String achievementValue, Color color}) {
    const double _textContainerWidth = 80;
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
              child: Text(
                OlukoLocalizations.get(context, achievementTitleKey),
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget profileNeumorphicAccomplishments({String achievementTitleKey, String achievementValue, Color color}) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievementValue,
            style: OlukoFonts.olukoSubtitleFont(customColor: color, custoFontWeight: FontWeight.w500),
          ),
          const SizedBox(
            width: 5,
          ),
          SizedBox(
            width: 80,
            child: Text(
              OlukoLocalizations.get(context, achievementTitleKey),
              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
