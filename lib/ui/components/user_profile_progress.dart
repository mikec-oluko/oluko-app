import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/points_card_panel_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/utils/screen_utils.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 10), child: widget.isMinimalRequested ? const SizedBox.shrink() : buildUserNeumorphicStatistics());
  }

  IntrinsicHeight buildUserNeumorphicStatistics() {
    return IntrinsicHeight(
        child: Padding(
      padding: EdgeInsets.only(top: _topPadding()),
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
                BlocBuilder<PointsCardBloc, PointsCardState>(builder: (context, state) {
                  if (state is PointsCardSuccess) {
                    return profileNeumorphicAccomplishments(
                        achievementTitleKey: ['mvt', 'points'], achievementValue: state.userPoints.toString(), color: OlukoColors.white, isClickable: true);
                  } else {
                    return OlukoCircularProgressIndicator();
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  double _topPadding() {
    return ScreenUtils.smallScreen(context) ? 5 : 15;
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

  Widget profileNeumorphicAccomplishments({List<String> achievementTitleKey, String achievementValue, Color color, bool isClickable = false}) {
    return GestureDetector(
        onTap: () => isClickable ? _pointsCardAction() : {},
        child: Padding(
            padding: EdgeInsets.only(bottom: ScreenUtils.smallScreen(context) ? 0 : 10),
            child: BlocBuilder<PointsCardPanelBloc, PointsCardPanelState>(
              builder: (context, state) {
                if (state is PointsCardPanelOpen) {
                  return _statisticsComponent(achievementValue, achievementTitleKey, isClicked: isClickable);
                } else {
                  return _statisticsComponent(achievementValue, achievementTitleKey);
                }
              },
            )));
  }

  Widget _textElem(List<String> achievementTitleKey, bool isClicked) {
    return Text(
      '${OlukoLocalizations.get(context, achievementTitleKey[0])}\n${OlukoLocalizations.get(context, achievementTitleKey[1])}',
      style: ScreenUtils.smallScreen(context) && isClicked
          ? OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w400)
          : OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w400),
    );
  }

  Widget _statisticsComponent(String achievementValue, List<String> achievementTitleKey, {bool isClicked = false}) {
    return Container(
        decoration: isClicked
            ? const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                color: OlukoColors.blackColorSemiTransparent,
              )
            : BoxDecoration(),
        child: Padding(padding: const EdgeInsets.all(5), child: _statisticsElement(achievementValue, achievementTitleKey, isClicked: isClicked)));
  }

  Widget _statisticsElement(String achievementValue, List<String> achievementTitleKey, {bool isClicked = false}) {
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
          child: _textElem(achievementTitleKey, isClicked),
        ),
        isClicked ? Icon(Icons.keyboard_arrow_right_rounded, color: OlukoColors.grayColor, size: ScreenUtils.smallScreen(context) ? 20 : 26) : SizedBox()
      ],
    );
  }

  void _pointsCardAction() {
    BlocProvider.of<PointsCardPanelBloc>(context).openPointsCardPanel();
  }

  TextStyle _style(bool clicked) {
    if (clicked) {
      return ScreenUtils.smallScreen(context)
          ? OlukoFonts.olukoMediumFont(customColor: OlukoColors.lightOrange, customFontWeight: FontWeight.w700)
          : OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.lightOrange, customFontWeight: FontWeight.w700);
    } else {
      return ScreenUtils.smallScreen(context)
          ? OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)
          : OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500);
    }
  }
}
