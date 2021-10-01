import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'coach_user_progress_component.dart';

class CoachUserProgressCard extends StatefulWidget {
  final UserStatistics userStats;
  const CoachUserProgressCard({this.userStats});

  @override
  _CoachUserProgressCardState createState() => _CoachUserProgressCardState();
}

class _CoachUserProgressCardState extends State<CoachUserProgressCard> {
  bool _isUserStatisticExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          OlukoLocalizations.get(context, 'activityStats'),
          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
        ),
        AnimatedContainer(
          decoration: ContainerGradient.getContainerGradientDecoration(),
          width: MediaQuery.of(context).size.width,
          clipBehavior: Clip.none,
          height: _isUserStatisticExpanded ? 180 : 100,
          duration: const Duration(seconds: 1),
          child: Stack(
            children: [
              Positioned(top: 0, right: 0, child: SizedBox()),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CoachUserProgressComponent(
                        progressValue: widget.userStats != null ? widget.userStats.completedClasses : 0,
                        nameOfField: OlukoLocalizations.get(context, 'classesCompleted')),
                    CoachUserProgressComponent(
                        progressValue: widget.userStats != null ? widget.userStats.completedChallenges : 0,
                        nameOfField: OlukoLocalizations.get(context, 'challengesCompleted')),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _isUserStatisticExpanded = !_isUserStatisticExpanded;
                          });
                        },
                        child: _isUserStatisticExpanded ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CoachUserProgressComponent(
                        progressValue: widget.userStats != null ? widget.userStats.completedCourses : 0,
                        nameOfField: OlukoLocalizations.get(context, 'coursesCompleted')),
                    CoachUserProgressComponent(
                      progressValue: 0,
                      nameOfField: OlukoLocalizations.get(context, 'appCompleted'),
                      needPercentage: true,
                    ),
                    Container(
                      width: 70,
                      height: 50,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
