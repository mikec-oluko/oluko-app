import 'package:flutter/material.dart';
import 'package:mvt_fitness/ui/components/course_progress_bar.dart';
import 'package:mvt_fitness/utils/screen_utils.dart';

class CourseCard extends StatefulWidget {
  final Image imageCover;
  final double progress;
  final double width;
  final double height;

  CourseCard({this.imageCover, this.progress, this.width, this.height});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
}
