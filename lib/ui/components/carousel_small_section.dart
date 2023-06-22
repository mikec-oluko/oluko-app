import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CarouselSmallSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Function() onOptionTap;
  final String optionLabel;
  final RouteEnum routeToGo;
  final UserResponse userToGetData;
  final CoachUser coachUser;

  CarouselSmallSection({this.title, this.children, this.onOptionTap, this.optionLabel, this.routeToGo, this.userToGetData, this.coachUser});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CarouselSmallSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: OlukoNeumorphism.isNeumorphismDesign ? 12 : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TitleBody(widget.title),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(top: 3.0, bottom: Platform.isAndroid ? 10 : 0),
                child: GestureDetector(
                  onTap: () {
                    goToRoute(widget.routeToGo);
                  },
                  child: Text(
                    OlukoLocalizations.get(context, 'viewAll'),
                    overflow: TextOverflow.ellipsis,
                    style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => widget.onOptionTap(),
                child: Text(
                  widget.optionLabel != null ? widget.optionLabel : '',
                  style: TextStyle(color: OlukoColors.primary, fontSize: 20),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0),
          child: Container(
              height: 120,
              child: Align(
                alignment: Alignment.centerLeft,
                child: OlukoNeumorphism.isNeumorphismDesign
                    ? ListView.builder(
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(children: widget.children);
                        })
                    : ListView(
                        shrinkWrap: true,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        scrollDirection: Axis.horizontal,
                        children: widget.children,
                      ),
                //   child:,
              )),
        )
      ]),
    );
  }

  goToRoute(RouteEnum routeToGo) {
    switch (routeToGo) {
      case RouteEnum.profileTransformationJourney:
        Navigator.pushNamed(
          context,
          routeLabels[RouteEnum.profileTransformationJourney],
          arguments: {'profileInfo': widget.userToGetData, 'viewAllPage': true},
        );
        break;
      case RouteEnum.profileAssessmentVideos:
        Navigator.pushNamed(context, routeLabels[RouteEnum.profileAssessmentVideos], arguments: {'profileInfo': widget.userToGetData});
        break;
      case RouteEnum.aboutCoach:
        Navigator.pushNamed(context, routeLabels[RouteEnum.aboutCoach],
            arguments: {'coachBannerVideo': widget.coachUser != null ? widget.coachUser.bannerVideo : null});
        break;
      case RouteEnum.profileChallenges:
        Navigator.pushNamed(context, routeLabels[RouteEnum.profileChallenges]);
        break;
      default:
    }
  }
}
