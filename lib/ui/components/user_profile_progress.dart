import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class UserProfileProgress extends StatefulWidget {
  final String challengesCompleted;
  final String coursesCompleted;
  final String classesCompleted;

  const UserProfileProgress(
      {this.challengesCompleted, this.coursesCompleted, this.classesCompleted})
      : super();

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
                  achievementTitle: OlukoLocalizations.of(context)
                      .find('challengesCompleted'),
                  achievementValue: widget.challengesCompleted),
              //SEPARATOR
              VerticalDivider(color: OlukoColors.grayColor),
              //COURSES COMPLETED
              profileAccomplishments(
                  achievementTitle:
                      OlukoLocalizations.of(context).find('coursesCompleted'),
                  achievementValue: widget.coursesCompleted),
              //SEPARATOR
              VerticalDivider(color: OlukoColors.grayColor),
              //CLASSES COMPLETED
              profileAccomplishments(
                  achievementTitle:
                      OlukoLocalizations.of(context).find('ClassesCompleted'),
                  achievementValue: widget.classesCompleted),
            ],
          ),
        )
      ],
    );
  }

  Widget profileAccomplishments(
      {String achievementTitle, String achievementValue}) {
    final double _textContainerWidth = 80;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //VALUE
        Column(
          children: [
            Text(
              achievementValue,
              style: OlukoFonts.olukoBigFont(
                  customColor: OlukoColors.primary,
                  custoFontWeight: FontWeight.w500),
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
                achievementTitle,
                style: OlukoFonts.olukoMediumFont(
                    customColor: OlukoColors.grayColor,
                    custoFontWeight: FontWeight.w300),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
