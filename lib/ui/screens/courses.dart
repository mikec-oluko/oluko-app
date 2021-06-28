import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
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
  SearchResults<Course> searchResults =
      SearchResults(query: '', suggestedItems: []);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
        bloc: BlocProvider.of<CourseBloc>(context)..getByCategories(),
        builder: (context, state) {
          return Scaffold(
              backgroundColor: Colors.black,
              appBar: state is CourseSuccess
                  ? OlukoAppBar<Course>(
                      title: 'Courses',
                      actions: [filterWidget()],
                      onSearchResults: (SearchResults results) =>
                          this.setState(() {
                        searchResults = SearchResults<Course>(
                            query: results.query,
                            suggestedItems:
                                List<Course>.from(results.suggestedItems));
                      }),
                      filterMethod: (String query, List<Course> collection) {
                        return collection
                            .where((course) =>
                                course.name
                                    .toLowerCase()
                                    .indexOf(query.toLowerCase()) ==
                                0)
                            .toList();
                      },
                      searchResultItems: state.values,
                      showSearchBar: true,
                    )
                  : null,
              bottomNavigationBar: OlukoBottomNavigationBar(),
              body: state is CourseSuccess
                  ? Container(
                      height: ScreenUtils.height(context),
                      child: ListView(
                        shrinkWrap: true,
                        children: searchResults.query != ''
                            ? [
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: searchSuggestions(
                                        searchResults.query,
                                        searchResults.suggestedItems))
                              ]
                            : [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Column(children: _mainPage(state)))
                              ],
                      ),
                    )
                  : OlukoCircularProgressIndicator());
        });
  }

  Widget searchSuggestions(String textInput, List<Course> listCollection) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: listCollection.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: RichText(
                      text: TextSpan(
                    children: [
                      TextSpan(
                          text: listCollection[index]
                              .name
                              .substring(0, textInput.length),
                          style: TextStyle(color: OlukoColors.primary)),
                      TextSpan(
                          text: listCollection[index]
                              .name
                              .substring(textInput.length),
                          style: TextStyle(color: Colors.white))
                    ],
                  )),
                ),
                Divider(
                  color: Colors.white,
                  height: 1,
                )
              ]));
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
                    .map((course) => getCourseCard(Image.network(
                          course.imageUrl,
                          frameBuilder: (context, Widget child, int frame,
                              bool wasSynchronouslyLoaded) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                frame == null
                                    ? Container(
                                        height: 120,
                                        child: OlukoCircularProgressIndicator())
                                    : SizedBox(),
                                AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                    child: child),
                              ],
                            );
                          },
                        )))
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
