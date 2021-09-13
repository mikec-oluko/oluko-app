import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
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

  CarouselSmallSection(
      {this.title,
      this.children,
      this.onOptionTap,
      this.optionLabel,
      this.routeToGo,
      this.userToGetData});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CarouselSmallSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: TitleBody(widget.title),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: TextButton(
                onPressed: () {
                  goToRoute(widget.routeToGo);
                },
                child: Text(
                  OlukoLocalizations.of(context).find('viewAll'),
                  style: TextStyle(color: OlukoColors.primary),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
              height: 120,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: widget.children,
                ),
              )),
        )
      ]),
    );
  }

  goToRoute(RouteEnum routeToGo) {
    switch (routeToGo) {
      case RouteEnum.profileTransformationJourney:
        Navigator.pushNamed(
            context, routeLabels[RouteEnum.profileTransformationJourney],
            arguments: {'profileInfo': widget.userToGetData});
        break;
      case RouteEnum.profileAssessmentVideos:
        Navigator.pushNamed(
            context, routeLabels[RouteEnum.profileAssessmentVideos]);
        break;
      case RouteEnum.profileChallenges:
        Navigator.pushNamed(context, routeLabels[RouteEnum.profileChallenges]);
        break;
      default:
    }
  }
}
