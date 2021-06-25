import 'package:flutter/material.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseCard extends StatefulWidget {
  final Image imageCover;
  final double progress;

  CourseCard({this.imageCover, this.progress});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).orientation == Orientation.portrait
          ? ScreenUtils.width(context) / 3.6
          : ScreenUtils.height(context) / 3.6,
      child: Column(children: [
        widget.imageCover,
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: widget.progress != null
                ? FractionallySizedBox(
                    widthFactor: 0.6,
                    child: CourseProgressBar(value: widget.progress))
                : SizedBox(),
          ),
        )
      ]),
    );
  }
}
