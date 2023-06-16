import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/classes_menu.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/three_dots_menu.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/user_utils.dart';

class CourseCard extends StatefulWidget {
  final Widget imageCover;
  final double progress;
  final double width;
  final double height;
  final List<UserResponse> userRecommendations;
  final CourseEnrollment actualCourse;
  final bool canUnenrollCourse;
  final bool friendRecommended;
  final Function() unrolledFunction;
  final List<ChallengeNavigation> challengeNavigations;
  final Function() closePanelFunction;
  final Function(ChallengeNavigation) audioNavigation;

  CourseCard(
      {this.imageCover,
      this.challengeNavigations,
      this.audioNavigation,
      this.closePanelFunction,
      this.progress,
      this.width,
      this.height,
      this.userRecommendations,
      this.actualCourse,
      this.unrolledFunction,
      this.canUnenrollCourse = false,
      this.friendRecommended = false});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CourseCard> {
  double userRadius = 15.0;
  final int _imageStackMaxLength = 3;

  @override
  Widget build(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign ? buildNeumorphicCourseCard() : buildCourseCard();
  }

  Container buildCourseCard() {
    return Container(
      width: widget.width,
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        if (widget.userRecommendations != null) Expanded(flex: 2, child: _userRecommendations(widget.userRecommendations)) else SizedBox(),
        Expanded(
            flex: 9,
            child: Stack(
              children: [
                widget.imageCover,
                Positioned(
                  top: 0,
                  right: -15,
                  child: Visibility(
                    visible: widget.canUnenrollCourse,
                    child: Align(
                        alignment: Alignment.topRight,
                        child: ThreeDotsMenu(
                          actualCourse: widget.actualCourse,
                          unrolledFunction: widget.unrolledFunction,
                        )),
                  ),
                ),
              ],
            )),
        if (widget.actualCourse.completion != null)
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                heightFactor: 1,
                widthFactor: 0.6,
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0), child: CourseProgressBar(value: widget.progress)),
              ),
            ),
          )
        else
          SizedBox()
      ]),
    );
  }

  Widget buildNeumorphicCourseCard() {
    return Container(
      width: widget.width,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (widget.userRecommendations != null && !widget.friendRecommended)
          Expanded(flex: 2, child: _userRecommendations(widget.userRecommendations))
        else
          const SizedBox.shrink(),
        Neumorphic(
          style: OlukoNeumorphism.getNeumorphicStyleForCardElement(),
          child: Stack(
            children: [widget.imageCover, unenrollMenu(), classesMenu()],
          ),
        ),
        if (widget.progress != null)
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: CourseProgressBar(
                    value: widget.progress,
                    color: OlukoColors.primary,
                  )),
            ),
          )
        else
          const SizedBox.shrink(),
        if (widget.userRecommendations != null && widget.friendRecommended)
          Expanded(flex: 2, child: _userRecommendations(widget.userRecommendations, friendRecommended: widget.friendRecommended))
        else
          const SizedBox.shrink(),
      ]),
    );
  }

  Widget unenrollMenu() {
    return Positioned(
      top: 0,
      right: -15,
      child: Visibility(
        visible: widget.canUnenrollCourse,
        child: Align(
            alignment: Alignment.topRight,
            child: ThreeDotsMenu(
              actualCourse: widget.actualCourse,
              unrolledFunction: widget.unrolledFunction,
            )),
      ),
    );
  }

  Widget classesMenu() {
    return Positioned(
      top: 0,
      right: -15,
      child: Visibility(
        visible: widget.challengeNavigations != null && widget.challengeNavigations.length > 1,
        child: Align(
            alignment: Alignment.topRight,
            child: ClassesMenu(
                challengeNavigations: widget.challengeNavigations, closePanelFunction: widget.closePanelFunction, audioNavigation: widget.audioNavigation)),
      ),
    );
  }

  Widget _userRecommendations(List<UserResponse> userRecommendations, {bool friendRecommended = false}) {
    List<UserResponse> userImageList = [];
    userImageList =
        userRecommendations.length < _imageStackMaxLength ? userRecommendations : userRecommendations.sublist(0, _imageStackMaxLength);
    String _friendsText = userRecommendations.length > 1 ? OlukoLocalizations.get(context, 'friends') : OlukoLocalizations.get(context, 'friend');
    return Stack(
        fit: StackFit.expand,
        alignment: Alignment.bottomRight,
        children: userImageList
            .asMap()
            .map((index, user) => MapEntry(
                friendRecommended
                    ? Positioned(
                        left: (index * (userRadius / 1.5)),
                        child: _userAvatar(user),
                      )
                    : Positioned(
                        right: (index + (userRecommendations.length <= _imageStackMaxLength ? 0 : 1)) * (userRadius / 1.5),
                        child: _userAvatar(user)),
                index))
            .keys
            .toList()
          ..add(Positioned(
            right: 0,
            bottom: userRadius * 0.5,
            child: friendRecommended
                ? Text(
                    '${userRecommendations.length} $_friendsText',
                    style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
                  )
                : Text(
                    userRecommendations.length > _imageStackMaxLength ? '...' : '',
                    style: TextStyle(color: Colors.white),
                  ),
          )));
  }

  Widget _userAvatar(UserResponse user) {
    return user.avatar == null ? 
    UserUtils.avatarImageDefault(
            maxRadius: 16,
            name: user.firstName,
            lastname: user.lastName,
          ) :
    CircleAvatar(
      minRadius: userRadius,
      backgroundImage: CachedNetworkImageProvider(user.avatar, maxHeight: 90, maxWidth: 90),
    );
  }
}
