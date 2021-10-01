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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //CHALLENGES COMPLETED
              profileAccomplishments(
                  achievementTitleKey: 'challengesCompleted', achievementValue: widget.challengesCompleted, color: OlukoColors.primary),
              //SEPARATOR
              profileVerticalDivider(),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              //COURSES COMPLETED
              profileAccomplishments(
                  achievementTitleKey: 'coursesCompleted', achievementValue: widget.coursesCompleted, color: OlukoColors.primary),
              //SEPARATOR
              profileVerticalDivider(),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              //CLASSES COMPLETED
              profileAccomplishments(
                  achievementTitleKey: 'classesCompleted', achievementValue: widget.classesCompleted, color: OlukoColors.white),
            ],
          ),
        )
      ],
    );
  }

  VerticalDivider profileVerticalDivider() {
    return const VerticalDivider(
      color: OlukoColors.white,
      thickness: 1,
      indent: 20,
      endIndent: 6,
      width: 1,
    );
  }

  Widget profileAccomplishments({String achievementTitleKey, String achievementValue, Color color}) {
    const double _textContainerWidth = 80;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //VALUE
        Column(
          children: [
            Text(
              achievementValue,
              style: OlukoFonts.olukoBigFont(customColor: color, custoFontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        //SUBTITLE
        Column(
          children: [
            Container(
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
}
