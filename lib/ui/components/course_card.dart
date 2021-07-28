import 'package:flutter/material.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseCard extends StatefulWidget {
  final Image imageCover;
  final double progress;
  final double width;
  final double height;
  final List<String> userRecommendationsAvatarUrls;

  CourseCard(
      {this.imageCover,
      this.progress,
      this.width,
      this.height,
      this.userRecommendationsAvatarUrls});

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
        widget.userRecommendationsAvatarUrls != null
            ? Expanded(
                flex: 2,
                child:
                    _userRecommendations(widget.userRecommendationsAvatarUrls))
            : SizedBox(),
        Expanded(flex: 9, child: widget.imageCover),
        widget.progress != null
            ? Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    heightFactor: 1,
                    widthFactor: 0.6,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 1.0, vertical: 8.0),
                        child: CourseProgressBar(value: widget.progress)),
                  ),
                ),
              )
            : SizedBox()
      ]),
    );
  }

  Widget _userRecommendations(List<String> userRecommendationImageUrls) {
    List<String> userImageList = userRecommendationImageUrls.length < 3
        ? userRecommendationImageUrls
        : userRecommendationImageUrls.sublist(0, 3);

    return Stack(
        alignment: Alignment.bottomRight,
        children: userImageList
            .asMap()
            .map((index, userUrl) => MapEntry(
                Positioned(
                  //Expression to overlap user avatars to a max of 3 items.
                  right: (index +
                          (userRecommendationImageUrls.length <= 3 ? 0 : 1)) *
                      (userRadius / 1.5),
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
              )));
  }
}
