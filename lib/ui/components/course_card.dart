import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/unenroll_menu.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseCard extends StatefulWidget {
  final Image imageCover;
  final double progress;
  final double width;
  final double height;
  final List<String> userRecommendationsAvatarUrls;
  final CourseEnrollment actualCourse;
  final bool canUnenrollCourse;
  final Function() unrolledFunction;

  CourseCard(
      {this.imageCover,
      this.progress,
      this.width,
      this.height,
      this.userRecommendationsAvatarUrls,
      this.actualCourse,
      this.unrolledFunction,
      this.canUnenrollCourse = false});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CourseCard> {
  double userRadius = 15.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        if (widget.userRecommendationsAvatarUrls != null)
          Expanded(flex: 2, child: _userRecommendations(widget.userRecommendationsAvatarUrls))
        else
          SizedBox(),
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
                        child: UnenrollCourse(
                          actualCourse: widget.actualCourse,
                          unrolledFunction: widget.unrolledFunction,
                        )),
                  ),
                )
              ],
            )),
        if (widget.progress != null)
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                heightFactor: 1,
                widthFactor: 0.6,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0), child: CourseProgressBar(value: widget.progress)),
              ),
            ),
          )
        else
          SizedBox()
      ]),
    );
  }

  Widget _userRecommendations(List<String> userRecommendationImageUrls) {
    List<String> userImageList =
        userRecommendationImageUrls.length < 3 ? userRecommendationImageUrls : userRecommendationImageUrls.sublist(0, 3);

    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: Stack(
          alignment: Alignment.bottomRight,
          children: userImageList
              .asMap()
              .map((index, userUrl) => MapEntry(
                  Positioned(
                    //Expression to overlap user avatars to a max of 3 items.
                    right: (index + (userRecommendationImageUrls.length <= 3 ? 0 : 1)) * (userRadius / 1.5),
                    child: CircleAvatar(
                      minRadius: userRadius,
                      backgroundImage: NetworkImage(userUrl),
                    ),
                  ),
                  index))
              .keys
              .toList()
            ..add(Positioned(
              right: 0,
              child: Text(
                //Show ellipsis if there are more than 3 user avatars
                userRecommendationImageUrls.length > 3 ? '...' : '',
                style: TextStyle(color: Colors.white),
              ),
            ))),
    );
  }
}
