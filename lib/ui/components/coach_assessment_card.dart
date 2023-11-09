import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachAssessmentCard extends StatefulWidget {
  final Task task;
  final bool introductionVideoDone;
  final List<TaskSubmission> assessmentVideos;
  final bool isAssessmentTask;
  final bool isForVerticalList;
  const CoachAssessmentCard({this.task, this.assessmentVideos, this.introductionVideoDone, this.isAssessmentTask = false, this.isForVerticalList = false});

  @override
  _CoachAssessmentCardState createState() => _CoachAssessmentCardState();
}

class _CoachAssessmentCardState extends State<CoachAssessmentCard> {
  @override
  Widget build(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign ? neumorphicTaskCard(context, isAssessmentTask: widget.isAssessmentTask) : defaultTaskCard(context);
  }

  GestureDetector defaultTaskCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.introductionVideoDone != null && widget.introductionVideoDone == false) {
          BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
        }
        Navigator.pushNamed(context, routeLabels[RouteEnum.assessmentVideos], arguments: {'isFirstTime': false});
      },
      child: Container(
        width: 250.0,
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
                    style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                  ),
                  checkAssessmentSubmitted(widget.task, widget.assessmentVideos) == false
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
                    style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    OlukoLocalizations.get(context, 'public'),
                    style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
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

  GestureDetector neumorphicTaskCard(BuildContext context, {bool isAssessmentTask = false}) {
    return GestureDetector(
      onTap: () {
        if (widget.introductionVideoDone != null && widget.introductionVideoDone == false) {
          BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
        }
        Navigator.pushNamed(context, routeLabels[RouteEnum.assessmentVideos], arguments: {'isFirstTime': false});
      },
      child: Container(
        width: widget.isForVerticalList ? ScreenUtils.width(context) - 40 : 250.0,
        height: 170,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoColors.white),
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
                    style: OlukoFonts.olukoSuperBigFont(customColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight, customFontWeight: FontWeight.bold),
                  ),
                  Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      checkAssessmentSubmitted(widget.task, widget.assessmentVideos)
                          ? 'assets/assessment/neumorphic_green_circle.png'
                          : 'assets/assessment/neumorphic_green_outlined.png',
                      scale: 4,
                    ),
                    checkAssessmentSubmitted(widget.task, widget.assessmentVideos)
                        ? Image.asset(
                            'assets/assessment/neumorphic_check.png',
                            scale: 4,
                          )
                        : const SizedBox.shrink()
                  ]),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.start,
                children: [
                  Text(
                    widget.task.shortDescription,
                    style: OlukoFonts.olukoBigFont(
                        customColor: checkAssessmentSubmitted(widget.task, widget.assessmentVideos)
                            ? OlukoColors.grayColor
                            : OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
                        customFontWeight: FontWeight.w300),
                  ),
                ],
              ),
              isAssessmentTask
                  ? Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Container(
                            color: OlukoNeumorphismColors.olukoNeumorphicBlueBackgroundColor,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  isTaskPublic(widget.task, widget.assessmentVideos)
                                      ? OlukoLocalizations.get(context, 'public').toUpperCase()
                                      : OlukoLocalizations.get(context, 'private').toUpperCase(),
                                  style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white, customFontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox())
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  bool checkAssessmentSubmitted(Task task, List<TaskSubmission> tasksSubmitted) =>
      tasksSubmitted.isNotEmpty && (tasksSubmitted.where((element) => element.task.id == task.id).isNotEmpty);

  bool isTaskPublic(Task task, List<TaskSubmission> tasksSubmitted) =>
      tasksSubmitted.isNotEmpty && (tasksSubmitted.where((element) => element.task.id == task.id && element.isPublic).isNotEmpty);
}
