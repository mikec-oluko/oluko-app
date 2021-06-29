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
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class Courses extends StatefulWidget {
  Courses({Key key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<Courses> {
  SearchResults<Course> searchResults =
      SearchResults(query: '', suggestedItems: []);
  bool showSearchSuggestions = false;
  double carouselSectionHeight;
  double cardsAspectRatio;
  int cardsToShowOnPortrait = 3;
  int cardsToShowOnLandscape = 5;

  @override
  Widget build(BuildContext context) {
    cardsAspectRatio = 0.69333;
    carouselSectionHeight =
        ((ScreenUtils.width(context) / _cardsToShow()) / cardsAspectRatio) + 75;
    return BlocBuilder<CourseBloc, CourseState>(
        bloc: BlocProvider.of<CourseBloc>(context)..getByCategories(),
        builder: (context, state) {
          return Scaffold(
              backgroundColor: Colors.black,
              appBar: state is CourseSuccess
                  ? OlukoAppBar<Course>(
                      title: OlukoLocalizations.of(context).find('courses'),
                      actions: [_filterWidget()],
                      onSearchSubmit: (SearchResults results) =>
                          this.setState(() {
                        showSearchSuggestions = false;
                      }),
                      onSearchResults: (SearchResults results) =>
                          this.setState(() {
                        showSearchSuggestions = true;
                        searchResults = SearchResults<Course>(
                            query: results.query,
                            suggestedItems:
                                List<Course>.from(results.suggestedItems));
                      }),
                      suggestionMethod: _suggestionMethod,
                      searchMethod: _searchMethod,
                      searchResultItems: state.values,
                      showSearchBar: true,
                    )
                  : null,
              bottomNavigationBar: OlukoBottomNavigationBar(),
              body: state is CourseSuccess
                  ? OrientationBuilder(builder: (context, orientation) {
                      return Container(
                        height: ScreenUtils.height(context),
                        width: ScreenUtils.width(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: searchResults.query == ''
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _mainPage(state),
                                )
                              : showSearchSuggestions
                                  ? _searchSuggestions(searchResults.query,
                                      searchResults.suggestedItems)
                                  : _searchResults(state.values),
                        ),
                      );
                    })
                  : OlukoCircularProgressIndicator());
        });
  }

  int _cardsToShow() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return cardsToShowOnPortrait;
    } else {
      return cardsToShowOnLandscape;
    }
  }

  List<Course> _suggestionMethod(String query, List<Course> collection) {
    return collection
        .where((course) =>
            course.name.toLowerCase().indexOf(query.toLowerCase()) == 0)
        .toList();
  }

  List<Course> _searchMethod(String query, List<Course> collection) {
    return collection
        .where(
            (course) => course.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  ListView _searchSuggestions(String textInput, List<Course> listCollection) {
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

  GridView _searchResults(List<Course> listCollection) {
    return GridView.count(
        childAspectRatio: cardsAspectRatio,
        shrinkWrap: true,
        crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 5,
        children: listCollection
            .map((e) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      child: _getCourseCard(
                    Image.network(
                      e.imageUrl,
                      fit: BoxFit.cover,
                      frameBuilder: _frameBuilder,
                    ),
                  )),
                ))
            .toList());
  }

  ListView _mainPage(CourseSuccess courseState) {
    return ListView(
      children: [
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: courseState.coursesByCategories.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final List<Course> coursesList =
                  courseState.coursesByCategories.values.elementAt(index);
              return CarouselSection(
                height: carouselSectionHeight,
                title:
                    courseState.coursesByCategories.keys.elementAt(index).name,
                optionLabel: OlukoLocalizations.of(context).find('viewAll'),
                children: coursesList
                    .map((course) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _getCourseCard(
                              Image.network(
                                course.imageUrl,
                                fit: BoxFit.cover,
                                frameBuilder: _frameBuilder,
                              ),
                              width: ScreenUtils.width(context) /
                                  (0.2 + _cardsToShow())),
                        ))
                    .toList(),
              );
            })
      ],
    );
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

  Widget _frameBuilder(
      context, Widget child, int frame, bool wasSynchronouslyLoaded) {
    return Stack(
      alignment: Alignment.center,
      children: [
        frame == null
            ? Container(height: 120, child: OlukoCircularProgressIndicator())
            : SizedBox(),
        AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: child),
      ],
    );
  }

  Widget _filterWidget() {
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
