import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ClassesMenu extends StatefulWidget {
  ClassesMenu({this.challengeNavigations}) : super();
  final List<ChallengeNavigation> challengeNavigations;

  @override
  _ClassesMenuState createState() => _ClassesMenuState();
}

class _ClassesMenuState extends State<ClassesMenu> {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return widget.challengeNavigations
            .map((item) => PopupMenuItem<String>(
                  onTap: () => Future(
                    () => navigateToSegmentDetail(item),
                  ),
                  value: widget.challengeNavigations[0].segmentId,
                  child: Center(
                      child: Text(OlukoLocalizations.get(context, 'class') + " " + (item.classIndex + 1).toString(),
                          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white))),
                  padding: EdgeInsets.zero,
                ))
            .toList();
      },
      color: OlukoColors.black,
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 36,
      ),
      iconSize: 36,
      padding: EdgeInsets.zero,
    ));
  }

  void navigateToSegmentDetail(ChallengeNavigation challenge) {
    Navigator.pushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
      'segmentIndex': challenge.segmentIndex,
      'classIndex': challenge.classIndex,
      'courseEnrollment': challenge.enrolledCourse,
      'courseIndex': challenge.courseIndex,
      'fromChallenge': true
    });
  }
}
