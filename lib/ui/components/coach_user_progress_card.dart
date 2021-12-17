import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'coach_user_progress_component.dart';

class CoachUserProgressCard extends StatefulWidget {
  final UserStatistics userStats;
  final bool startExpanded;
  const CoachUserProgressCard({this.userStats, this.startExpanded});

  @override
  _CoachUserProgressCardState createState() => _CoachUserProgressCardState();
}

class _CoachUserProgressCardState extends State<CoachUserProgressCard> {
  bool _isUserStatisticExpanded = false;

  @override
  void initState() {
    setState(() {
      _isUserStatisticExpanded = widget.startExpanded;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return userNeumorphicStatisticsPanel(context);
  }

  Column userStatisticsPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          OlukoLocalizations.get(context, 'activityStats'),
          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
        ),
        AnimatedContainer(
          decoration: UserInformationBackground.getContainerGradientDecoration(isNeumorphic: OlukoNeumorphism.isNeumorphismDesign),
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

  Widget userNeumorphicStatisticsPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Text(
          //   OlukoLocalizations.get(context, 'activityStats'),
          //   style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
          // ),
          AnimatedContainer(
            decoration: UserInformationBackground.getContainerGradientDecoration(isNeumorphic: OlukoNeumorphism.isNeumorphismDesign),
            width: MediaQuery.of(context).size.width,
            clipBehavior: Clip.none,
            height: 150,
            // height: _isUserStatisticExpanded ? 180 : 100,
            duration: const Duration(seconds: 1),
            child: Column(
              children: [
                Stack(
                  children: [
                    Positioned(top: 0, right: 0, child: SizedBox()),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CoachUserProgressComponent(
                              progressValue: widget.userStats != null ? widget.userStats.completedClasses : 0,
                              nameOfField: OlukoLocalizations.get(context, 'classesCompleted')),
                          CoachUserProgressComponent(
                              progressValue: widget.userStats != null ? widget.userStats.completedChallenges : 0,
                              nameOfField: OlukoLocalizations.get(context, 'challengesCompleted')),
                          // TextButton(
                          //     onPressed: () {
                          //       setState(() {
                          //         _isUserStatisticExpanded = !_isUserStatisticExpanded;
                          //       });
                          //     },
                          //     child: _isUserStatisticExpanded ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down)),
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                        width: 1,
                      ),
                    ),
                    Center(
                      child: Container(
                        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 90),
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
                          // Container(
                          //   width: 70,
                          //   height: 50,
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
