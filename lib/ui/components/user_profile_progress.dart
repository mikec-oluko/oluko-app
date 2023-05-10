import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/points_card_panel_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/points_card_component.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

import '../../models/points_card.dart';
import '../../models/user_response.dart';

class UserProfileProgress extends StatefulWidget {
  final String challengesCompleted;
  final String coursesCompleted;
  final String classesCompleted;
  final bool isMinimalRequested;
  final UserResponse currentUser;

  const UserProfileProgress({this.challengesCompleted, this.coursesCompleted, this.classesCompleted, this.isMinimalRequested = false, this.currentUser})
      : super();

  @override
  _UserProfileProgressState createState() => _UserProfileProgressState();
}

class _UserProfileProgressState extends State<UserProfileProgress> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: widget.isMinimalRequested
          ? const SizedBox.shrink()
          : OlukoNeumorphism.isNeumorphismDesign
              ? buildUserNeumorphicStatistics()
              : buildUserStatistics(),
    );
  }

  IntrinsicHeight buildUserNeumorphicStatistics() {
    return IntrinsicHeight(
        child: Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                profileNeumorphicAccomplishments(
                    achievementTitleKey: ['challenges', 'completed'], achievementValue: widget.challengesCompleted, color: OlukoColors.white),
                profileNeumorphicAccomplishments(
                    achievementTitleKey: ['classes', 'completed'], achievementValue: widget.classesCompleted, color: OlukoColors.white),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Align(child: profileVerticalDivider(isNeumorphic: true))),
          Expanded(
            child: Column(
              children: [
                profileNeumorphicAccomplishments(
                    achievementTitleKey: ['courses', 'completed'], achievementValue: widget.coursesCompleted, color: OlukoColors.white),
                profileNeumorphicAccomplishments(
                    achievementTitleKey: ['mvt', 'points'], achievementValue: widget.coursesCompleted, color: OlukoColors.white, isClickable: true),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Column buildUserStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileAccomplishments(achievementTitleKey: 'challengesCompleted', achievementValue: widget.challengesCompleted, color: OlukoColors.primary),
              profileVerticalDivider(),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              profileAccomplishments(achievementTitleKey: 'coursesCompleted', achievementValue: widget.coursesCompleted, color: OlukoColors.primary),
              profileVerticalDivider(),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              profileAccomplishments(achievementTitleKey: 'classesCompleted', achievementValue: widget.classesCompleted, color: OlukoColors.white),
            ],
          ),
        )
      ],
    );
  }

  VerticalDivider profileVerticalDivider({bool isNeumorphic = false}) {
    return VerticalDivider(
      color: isNeumorphic ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.white,
      thickness: 1,
      indent: isNeumorphic ? 0 : 20,
      endIndent: 6,
      width: 1,
    );
  }

  Widget profileAccomplishments({String achievementTitleKey, String achievementValue, Color color}) {
    const double _textContainerWidth = 88;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              achievementValue,
              style: OlukoFonts.olukoBigFont(customColor: color, customFontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Column(
          children: [
            SizedBox(
              width: _textContainerWidth,
              child: Text(OlukoLocalizations.get(context, achievementTitleKey),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w300)),
            ),
          ],
        ),
      ],
    );
  }

  Widget profileNeumorphicAccomplishments({List<String> achievementTitleKey, String achievementValue, Color color, bool isClickable = false}) {
    final Text textElem = Text(
      '${OlukoLocalizations.get(context, achievementTitleKey[0])}\n${OlukoLocalizations.get(context, achievementTitleKey[1])}',
      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w400),
    );
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => isClickable ? _pointsCardAction() : {},
          child: BlocBuilder<PointsCardPanelBloc, PointsCardPanelState>(
            builder: (context, state) {
              if (state is PointsCardPanelOpen) {
                return _statisticsComponent(achievementValue, textElem, isClicked: isClickable);
              } else {
                return _statisticsComponent(achievementValue, textElem);
              }
            },
          ),
        ));
  }

  Widget _statisticsComponent(String achievementValue, Text textElem, {bool isClicked = false}) {
    return /*isClicked
        ?*/
        Container(
            decoration: isClicked
                ? const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    color: OlukoColors.blackColorSemiTransparent,
                  )
                : BoxDecoration(),
            child: Padding(padding: const EdgeInsets.all(5), child: _statisticsElement(achievementValue, textElem, isClicked: isClicked)));
    // : _statisticsElement(achievementValue, textElem);
  }

  Widget _statisticsElement(String achievementValue, Text textElem, {bool isClicked = false}) {
    return Row(
      children: [
        Text(
          achievementValue,
          style: _style(isClicked),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: textElem,
        ),
        isClicked ? Icon(Icons.keyboard_arrow_right_rounded, color: OlukoColors.grayColor, size: 26) : SizedBox()
      ],
    );
  }

  void _pointsCardAction() {
    BlocProvider.of<PointsCardPanelBloc>(context).openPointsCardPanel();
    BlocProvider.of<PointsCardBloc>(context).get(widget.currentUser.id);
  }

  TextStyle _style(bool clicked) {
    if (clicked) {
      return OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.lightOrange, customFontWeight: FontWeight.w700);
    } else {
      return OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500);
    }
  }
}
