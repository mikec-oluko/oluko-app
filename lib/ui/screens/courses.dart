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
import 'package:oluko_app/ui/components/filter_selector.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/search_results_grid.dart';
import 'package:oluko_app/ui/components/search_suggestions.dart';
import 'package:oluko_app/utils/image_utils.dart';
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
  int searchResultsPortrait = 2;
  int searchResultsLandscape = 5;
  TextEditingController searchBarController;
  final searchKey = GlobalKey<SearchState>();

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
                      searchKey: searchKey,
                      title: OlukoLocalizations.of(context).find('courses'),
                      actions: [_filterWidget()],
                      onSearchSubmit: (SearchResults results) =>
                          this.setState(() {
                        showSearchSuggestions = false;
                        searchResults = results;
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
                      whenSearchBarInitialized:
                          (TextEditingController controller) =>
                              searchBarController = controller,
                    )
                  : null,
              bottomNavigationBar: OlukoBottomNavigationBar(),
              body: state is CourseSuccess
                  ? OrientationBuilder(builder: (context, orientation) {
                      return Container(
                        height: ScreenUtils.height(context),
                        width: ScreenUtils.width(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: searchResults.query == ''
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 8, right: 8),
                                  child: _mainPage(state),
                                )
                              : showSearchSuggestions
                                  ? SearchSuggestions<Course>(
                                      textInput: searchResults.query,
                                      itemList: searchResults.suggestedItems,
                                      onPressed: (dynamic item) => searchKey
                                          .currentState
                                          .updateSearchResults(item.name),
                                      keyNameList: searchResults.suggestedItems
                                          .map((e) => e.name)
                                          .toList())
                                  : SearchResultsGrid<Course>(
                                      childAspectRatio: cardsAspectRatio,
                                      crossAxisCount:
                                          MediaQuery.of(context).orientation ==
                                                  Orientation.portrait
                                              ? searchResultsPortrait
                                              : searchResultsLandscape,
                                      textInput: searchResults.query,
                                      itemList: searchResults.searchResults),
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
                                frameBuilder: (BuildContext context,
                                        Widget child,
                                        int frame,
                                        bool wasSynchronouslyLoaded) =>
                                    ImageUtils.frameBuilder(context, child,
                                        frame, wasSynchronouslyLoaded,
                                        height: 120),
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

  Widget _showFilterMenu(List<dynamic> items) {
    return FilterSelector<Course>(
      itemList: Map<Course, String>.fromIterable(items,
          key: (course) => course, value: (course) => course.name),
    );
  }

  Widget _filterWidget() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, top: 4),
      child: Icon(
        Icons.filter_alt_outlined,
        color: OlukoColors.appBarIcon,
        size: 25,
      ),
    );
  }
}
