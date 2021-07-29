import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/ui/screens/courses/classes.dart';
import 'package:oluko_app/utils/image_utils.dart';

import 'course_card.dart';

class SearchResultsGrid<T> extends StatefulWidget {
  final String textInput;
  final List<T> itemList;
  final double childAspectRatio;
  final int crossAxisCount;

  SearchResultsGrid(
      {this.textInput,
      this.itemList,
      this.childAspectRatio,
      this.crossAxisCount});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SearchResultsGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
        childAspectRatio: widget.childAspectRatio,
        shrinkWrap: true,
        crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 5,
        children: widget.itemList
            .map((e) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context2) => BlocProvider<AuthBloc>(
                                  create: (context2) =>
                                      BlocProvider.of<AuthBloc>(context),
                                  child: Classes(
                                      course:
                                          e),
                                ))),
                    child: _getCourseCard(
                      Image.network(
                        e.imageUrl,
                        fit: BoxFit.cover,
                        frameBuilder: (BuildContext context, Widget child,
                                int frame, bool wasSynchronouslyLoaded) =>
                            ImageUtils.frameBuilder(
                                context, child, frame, wasSynchronouslyLoaded,
                                height: 120),
                      ),
                    ),
                  )),
                ))
            .toList());
  }

  CourseCard _getCourseCard(Image image,
      {double progress, double width, double height}) {
    return CourseCard(
      width: width,
      height: height,
      imageCover: image,
      progress: progress,
    );
  }
}
