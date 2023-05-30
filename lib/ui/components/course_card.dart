import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/classes_menu.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/three_dots_menu.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseCard extends StatefulWidget {
  final Widget imageCover;
  final double progress;
  final double width;
  final double height;
  final List<String> userRecommendationsAvatarUrls;
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
      this.userRecommendationsAvatarUrls,
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
        if (widget.userRecommendationsAvatarUrls != null) Expanded(flex: 2, child: _userRecommendations(widget.userRecommendationsAvatarUrls)) else SizedBox(),
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
        if (widget.userRecommendationsAvatarUrls != null && !widget.friendRecommended)
          Expanded(flex: 2, child: _userRecommendations(widget.userRecommendationsAvatarUrls))
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
        if (widget.userRecommendationsAvatarUrls != null && widget.friendRecommended)
          Expanded(flex: 2, child: _userRecommendations(widget.userRecommendationsAvatarUrls, friendRecommended: widget.friendRecommended))
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

  Widget _userRecommendations(List<String> userRecommendationImageUrls, {bool friendRecommended = false}) {
    List<String> userImageList = [];
    userImageList =
        userRecommendationImageUrls.length < _imageStackMaxLength ? userRecommendationImageUrls : userRecommendationImageUrls.sublist(0, _imageStackMaxLength);
    String _friendsText = userRecommendationImageUrls.length > 1 ? OlukoLocalizations.get(context, 'friends') : OlukoLocalizations.get(context, 'friend');
    return Stack(
        fit: StackFit.expand,
        alignment: Alignment.bottomRight,
        children: userImageList
            .asMap()
            .map((index, userUrl) => MapEntry(
                friendRecommended
                    ? Positioned(
                        left: (index * (userRadius / 1.5)),
                        child: _userAvatar(userUrl),
                      )
                    : Positioned(
                        right: (index + (userRecommendationImageUrls.length <= _imageStackMaxLength ? 0 : 1)) * (userRadius / 1.5),
                        child: _userAvatar(userUrl)),
                index))
            .keys
            .toList()
          ..add(Positioned(
            right: 0,
            bottom: userRadius * 0.5,
            child: friendRecommended
                ? Text(
                    '${userRecommendationImageUrls.length} $_friendsText',
                    style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
                  )
                : Text(
                    userRecommendationImageUrls.length > _imageStackMaxLength ? '...' : '',
                    style: TextStyle(color: Colors.white),
                  ),
          )));
  }

  CircleAvatar _userAvatar(String userUrl) {
    return CircleAvatar(
      minRadius: userRadius,
      backgroundImage: CachedNetworkImageProvider(userUrl, maxHeight: 90, maxWidth: 90),
    );
  }
}
