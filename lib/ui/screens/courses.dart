import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class Courses extends StatefulWidget {
  Courses({Key key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<Courses> {
  List<Course> courses = [
    Course(
      imageUrl: 'assets/courses/course_sample_1.png',
    )
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
        bloc: BlocProvider.of<CourseBloc>(context)..getByCategories(),
        builder: (context, state) {
          return Scaffold(
              backgroundColor: Colors.black,
              appBar: state is CourseSuccess
                  ? OlukoAppBar(
                      title: 'Courses',
                      actions: [filterWidget()],
                      onSearchResults: (SearchResults results) =>
                          print(results.toJson().toString()),
                      searchResultItems: [],
                      showSearchBar: true,
                    )
                  : null,
              bottomNavigationBar: OlukoBottomNavigationBar(),
              body: state is CourseSuccess
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Container(
                        height: ScreenUtils.height(context),
                        child: ListView(
                          shrinkWrap: true,
                          children: _mainPage(state),
                        ),
                      ))
                  : OlukoCircularProgressIndicator());
        });
  }

  List<Widget> _mainPage(CourseSuccess courseState) {
    return [
      Column(children: [
        CarouselSection(
          title: 'Active Courses',
          children: [
            getCourseCard(Image.asset('assets/courses/course_sample_1.png'),
                progress: 0.3),
            getCourseCard(Image.asset('assets/courses/course_sample_2.png'),
                progress: 0.7),
          ],
        ),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: courseState.coursesByCategories.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final List<Course> coursesList =
                  courseState.coursesByCategories.values.elementAt(index);
              return CarouselSection(
                title:
                    courseState.coursesByCategories.keys.elementAt(index).name,
                optionLabel: 'View All',
                children: coursesList
                    .map((course) =>
                        getCourseCard(Image.network(course.imageUrl)))
                    .toList(),
              );
            }),
      ])
    ];
  }

  Widget getCourseCard(Image image, {double progress}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: CourseCard(
        imageCover: image,
        progress: progress,
      ),
    );
  }

  Widget filterWidget() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, top: 4),
      child: Icon(
        Icons.filter_alt_outlined,
        color: Colors.white,
        size: 25,
      ),
    );
  }
}
