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
                      achievementTitleKey: ['challenges', 'completed'],
                      achievementValue: widget.challengesCompleted,
                      color: OlukoColors.white),
                  profileNeumorphicAccomplishments(
                      achievementTitleKey: ['classes', 'completed'], achievementValue: widget.classesCompleted, color: OlukoColors.white),
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
                      achievementTitleKey: ['courses', 'completed'], achievementValue: widget.coursesCompleted, color: OlukoColors.white),
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
              style: OlukoFonts.olukoBigFont(customColor: color, customFontWeight: FontWeight.w500),
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
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w300)),
            ),
          ],
        ),
      ],
    );
  }

  Widget profileNeumorphicAccomplishments({List<String> achievementTitleKey, String achievementValue, Color color}) {
    final textElem = Text(
      '${OlukoLocalizations.get(context, achievementTitleKey[0])}\n${OlukoLocalizations.get(context, achievementTitleKey[1])}',
      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w400),
    );
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
          Expanded(
            child: textElem,
          ),
        ],
      ),
    );
  }
}
