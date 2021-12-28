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
  bool showDivider = true;

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
      child: Wrap(
        children: [
          // Text(
          //   OlukoLocalizations.get(context, 'activityStats'),
          //   style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
          // ),
          AnimatedContainer(
              onEnd: () {
                setState(() {
                  showDivider = !showDivider;
                });
              },
              decoration: UserInformationBackground.getContainerGradientDecoration(
                  isNeumorphic: OlukoNeumorphism.isNeumorphismDesign, customBorder: true),
              width: MediaQuery.of(context).size.width,
              clipBehavior: Clip.none,
              // height: 150,
              height: _isUserStatisticExpanded ? MediaQuery.of(context).size.height / 6 : MediaQuery.of(context).size.height / 12,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 20,
                    child: CoachUserProgressComponent(
                        progressValue: widget.userStats != null ? widget.userStats.completedClasses : 0,
                        nameOfField: OlukoLocalizations.get(context, 'classesCompleted')),
                  ),
                  Positioned(
                    top: 10,
                    right: 0,
                    child: CoachUserProgressComponent(
                        progressValue: widget.userStats != null ? widget.userStats.completedChallenges : 0,
                        nameOfField: OlukoLocalizations.get(context, 'challengesCompleted')),
                  ),
                  Align(
                      alignment: Alignment.center,
                      // top: MediaQuery.of(context).size.height / 8,
                      child: _isUserStatisticExpanded
                          ? AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                              width: MediaQuery.of(context).size.width,
                              height: showDivider ? 1 : 0,
                            )
                          : SizedBox.shrink()),
                  Positioned(
                    bottom: 0,
                    left: 20,
                    child: AnimatedContainer(
                      height: _isUserStatisticExpanded ? MediaQuery.of(context).size.height / 12 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: CoachUserProgressComponent(
                          progressValue: widget.userStats != null ? widget.userStats.completedCourses : 0,
                          nameOfField: OlukoLocalizations.get(context, 'coursesCompleted')),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: AnimatedContainer(
                      height: _isUserStatisticExpanded ? MediaQuery.of(context).size.height / 12 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: CoachUserProgressComponent(
                        progressValue: 0,
                        nameOfField: OlukoLocalizations.get(context, 'appCompleted'),
                        needPercentage: true,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    // left: (MediaQuery.of(context).size.width - 40) / 2.5,
                    child: Container(
                      color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                      width: 1,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                ],
              )),
          Container(
            // clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                color: OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat,
                gradient: new LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    stops: [0.02, 0.02],
                    colors: [Colors.black, OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat]),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
            width: MediaQuery.of(context).size.width - 60,
            height: 40,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isUserStatisticExpanded = !_isUserStatisticExpanded;
                  //  showDivider = !showDivider;
                });
              },
              icon: Icon(
                Icons.arrow_drop_up,
                color: OlukoColors.white,
                size: 24,
              ),
            ),
            // color: Colors.red,
            // height: _isUserStatisticExpanded ? 180 : 100,
          )
        ],
      ),
    );
  }
}
