import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachAssessmentCard extends StatefulWidget {
  final Task task;
  final List<TaskSubmission> assessmentVideos;
  const CoachAssessmentCard({this.task, this.assessmentVideos});

  @override
  _CoachAssessmentCardState createState() => _CoachAssessmentCardState();
}

class _CoachAssessmentCardState extends State<CoachAssessmentCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeLabels[RouteEnum.assessmentVideos],
            arguments: {'isFirstTime': false});
      },
      child: Container(
        width: 250,
        height: 170,
        color: OlukoColors.challengesGreyBackground,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task.name,
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoColors.white,
                        custoFontWeight: FontWeight.w500),
                  ),
                  checkAssessmentSubmitted(
                              widget.task, widget.assessmentVideos) ==
                          false
                      ? Image.asset(
                          'assets/assessment/check_ellipse.png',
                          scale: 4,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          child: Stack(alignment: Alignment.center, children: [
                            Image.asset(
                              'assets/assessment/check_ellipse.png',
                              scale: 4,
                            ),
                            Image.asset(
                              'assets/assessment/check.png',
                              scale: 4,
                            )
                          ]),
                        ),
                ],
              ),
              Wrap(
                children: [
                  Text(
                    widget.task.description,
                    style: OlukoFonts.olukoMediumFont(
                        customColor: OlukoColors.grayColor,
                        custoFontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    OlukoLocalizations.get(context, 'public'),
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoColors.grayColor,
                        custoFontWeight: FontWeight.w500),
                  ),
                  Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      'assets/assessment/green_ellipse.png',
                      scale: 4,
                    ),
                    Image.asset(
                      'assets/home/right_icon.png',
                      scale: 4,
                    )
                  ])
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  checkAssessmentSubmitted(Task task, List<TaskSubmission> tasksSubmitted) {
    bool result = false;
    if (tasksSubmitted.length == null || tasksSubmitted.length == 0) {
      result = false;
    } else {
      if (tasksSubmitted
          .where((element) => element.task.id == task.id)
          .isNotEmpty) {
        result = true;
      } else {
        result = false;
      }
    }

    return result;
  }
}
