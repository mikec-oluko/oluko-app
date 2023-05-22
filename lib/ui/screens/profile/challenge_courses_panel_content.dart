import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_panel_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ChallengeCoursesPanelContent extends StatefulWidget {
  final PanelController panelController;

  ChallengeCoursesPanelContent({this.panelController});

  @override
  _State createState() => _State();
}

class _State extends State<ChallengeCoursesPanelContent> {
  List<Movement> segmentMovements;
  Function(ChallengeNavigation) audioNavigation;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            decoration: OlukoNeumorphism.isNeumorphismDesign
                ? BoxDecoration(
                    color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)))
                : decorationImage(),
            child: Column(children: [
              SizedBox(height: OlukoNeumorphism.isNeumorphismDesign ? 5 : 15),
              !OlukoNeumorphism.isNeumorphismDesign
                  ? SizedBox.shrink()
                  : Center(
                      child: Container(
                        width: 50,
                        child: Image.asset('assets/courses/horizontal_vector.png', scale: 2, color: OlukoColors.grayColor),
                      ),
                    ),
              _content()
            ])));
  }

  Widget courseGridView(List<Widget> courseCards) {
    return Container(
        height: (ScreenUtils.height(context) / 4) * 2.36,
        width: ScreenUtils.width(context),
        child: GridView.count(childAspectRatio: 3.3 / 5, mainAxisSpacing: 15, crossAxisSpacing: 15, crossAxisCount: 3, children: courseCards));
  }

  Widget getCourseCard(List<ChallengeNavigation> challengeNavigations) {
    return GestureDetector(
      onTap: () {
        if (challengeNavigations.length == 1) {
          if (audioNavigation != null) {
            audioNavigation(challengeNavigations[0]);
          } else {
            navigateToSegmentDetail(challengeNavigations[0]);
          }
          widget.panelController.close();
        }
      },
      child: CourseCard(
          audioNavigation: audioNavigation,
          closePanelFunction: () => widget.panelController.close(),
          challengeNavigations: challengeNavigations,
          imageCover: _generateImageCourse(challengeNavigations[0].enrolledCourse.course.image)),
    );
  }

  Image _generateImageCourse(String imageUrl) {
    if (imageUrl != null) {
      return Image(
        image: CachedNetworkImageProvider(imageUrl),
        fit: BoxFit.cover,
      );
    }
    return Image.asset("assets/courses/course_sample_7.png");
  }

  Widget _content() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          Text(OlukoLocalizations.of(context).find('cousesPanelText'),
              textAlign: TextAlign.left, style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.white)),
          const SizedBox(height: 15),
          BlocBuilder<CoursePanelBloc, CoursePanelState>(builder: (context, state) {
            if (state is CoursePanelSuccess) {
              List<Widget> courseCards = [];
              audioNavigation = state.audioNavigation;
              for (List<ChallengeNavigation> challenges in state.challengeNavigations.values) {
                courseCards.add(getCourseCard(challenges));
              }
              return courseGridView(courseCards);
            } else {
              return SizedBox();
            }
          })
        ]));
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

  BoxDecoration decorationImage() {
    return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [OlukoNeumorphismColors.initialGradientColorDark, OlukoNeumorphismColors.finalGradientColorDark],
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)));
  }
}
