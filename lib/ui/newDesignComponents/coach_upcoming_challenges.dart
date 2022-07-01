import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/coach_horizontal_carousel_component.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachUpcomingChallenges extends StatefulWidget {
  final List<Widget> challengesContentList;
  const CoachUpcomingChallenges({@required this.challengesContentList}) : super();

  @override
  State<CoachUpcomingChallenges> createState() => _CoachUpcomingChallengesState();
}

class _CoachUpcomingChallengesState extends State<CoachUpcomingChallenges> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0),
          child: Text(
            OlukoLocalizations.get(context, 'upcomings'),
            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
          ),
        ),
        if (OlukoNeumorphism.isNeumorphismDesign)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [Wrap(children: widget.challengesContentList)]),
          )
        else
          CoachHorizontalCarousel(contentToDisplay: widget.challengesContentList),
      ],
    );
  }
}
