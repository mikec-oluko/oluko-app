import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/ui/screens/courses/course_marketing.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';

import '../../routes.dart';
import 'course_card.dart';

class SearchResultsGrid<T> extends StatefulWidget {
  final String textInput;
  final List<T> itemList;
  final double childAspectRatio;
  final int crossAxisCount;

  SearchResultsGrid({this.textInput, this.itemList, this.childAspectRatio, this.crossAxisCount});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SearchResultsGrid> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  @override
  Widget build(BuildContext context) {
    return GridView.count(
        childAspectRatio: widget.childAspectRatio,
        shrinkWrap: true,
        crossAxisCount: widget.crossAxisCount,
        padding: EdgeInsets.only(bottom: ScreenUtils.height(context) * 0.15),
        children: widget.itemList
            .map((e) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      child: GestureDetector(
                    //TODO: not generic, depends on T being course only
                    onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                        arguments: {'course': e as Course, 'fromCoach': false, 'isCoachRecommendation': false}),
                    child: e.image != null
                        ? _getCourseCard(
                            Image(
                              image: CachedNetworkImageProvider(e.image as String),
                              fit: BoxFit.cover,
                              frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                                  ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 120),
                            ),
                          )
                        : Image(image: defaultImage),
                  )),
                ))
            .toList());
  }

  CourseCard _getCourseCard(Image image, {double progress, double width, double height}) {
    return CourseCard(
      width: width,
      height: height,
      imageCover: image,
      progress: progress,
    );
  }
}
