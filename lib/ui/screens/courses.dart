import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';
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
  double carouselSectionHeight;
  TextEditingController searchBarController;
  List selectedTags = [];
  //Used to trigger AppBar Search Functions
  final searchKey = GlobalKey<SearchState>();
  //Flags to control on-screen components
  bool showSearchSuggestions = false;
  bool showFilterSelector = false;
  //Constants to display cards
  final double cardsAspectRatio = 0.69333;
  final int cardsToShowOnPortrait = 3;
  final int cardsToShowOnLandscape = 5;
  final int searchResultsPortrait = 2;
  final int searchResultsLandscape = 5;

  @override
  Widget build(BuildContext context) {
    carouselSectionHeight =
        ((ScreenUtils.width(context) / _cardsToShow()) / cardsAspectRatio) + 75;
    return BlocBuilder<CourseBloc, CourseState>(
        bloc: BlocProvider.of<CourseBloc>(context)..getByCategories(),
        builder: (context, courseState) {
          return BlocBuilder<TagBloc, TagState>(
              bloc: BlocProvider.of<TagBloc>(context)..getByCategories(),
              builder: (context, tagState) {
                return Scaffold(
                    backgroundColor: Colors.black,
                    appBar: _appBar(courseState),
                    bottomNavigationBar: OlukoBottomNavigationBar(),
                    body: courseState is CourseSuccess && tagState is TagSuccess
                        ? OrientationBuilder(builder: (context, orientation) {
                            return Container(
                              height: ScreenUtils.height(context),
                              width: ScreenUtils.width(context),
                              child: showFilterSelector
                                  ? _filterSelector(tagState)
                                  : searchResults.query.isEmpty
                                      ? _mainPage(courseState)
                                      : showSearchSuggestions
                                          ? _searchSuggestions()
                                          : _searchResults(),
                            );
                          })
                        : OlukoCircularProgressIndicator());
              });
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

  Widget _searchResults() {
    return SearchResultsGrid<Course>(
        childAspectRatio: cardsAspectRatio,
        crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? searchResultsPortrait
                : searchResultsLandscape,
        textInput: searchResults.query,
        itemList: searchResults.searchResults);
  }

  Widget _searchSuggestions() {
    return SearchSuggestions<Course>(
        textInput: searchResults.query,
        itemList: searchResults.suggestedItems,
        onPressed: (dynamic item) =>
            searchKey.currentState.updateSearchResults(item.name),
        keyNameList: searchResults.suggestedItems.map((e) => e.name).toList());
  }

  Widget _appBar(CourseState state) {
    return state is CourseSuccess
        ? OlukoAppBar<Course>(
            searchKey: searchKey,
            title: OlukoLocalizations.of(context).find('courses'),
            actions: [_filterWidget()],
            onSearchSubmit: (SearchResults results) => this.setState(() {
              showSearchSuggestions = false;
              searchResults = results;
            }),
            onSearchResults: (SearchResults results) => this.setState(() {
              showSearchSuggestions = true;
              searchResults = SearchResults<Course>(
                  query: results.query,
                  suggestedItems: List<Course>.from(results.suggestedItems));
            }),
            suggestionMethod: _suggestionMethod,
            searchMethod: _searchMethod,
            searchResultItems: state.values,
            showSearchBar: true,
            whenSearchBarInitialized: (TextEditingController controller) =>
                searchBarController = controller,
          )
        : null;
  }

  List<Course> _searchMethod(String query, List<Course> collection) {
    return collection
        .where(
            (course) => course.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Widget _mainPage(CourseSuccess courseState) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 8, right: 8),
      child: ListView(
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
                  title: courseState.coursesByCategories.keys
                      .elementAt(index)
                      .name,
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
      ),
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

  Widget _filterSelector(state) {
    return Padding(
        padding: EdgeInsets.only(top: 15.0, left: 8, right: 8),
        child: FilterSelector<Tag>(
          itemList: Map.fromIterable(state.values,
              key: (course) => course, value: (course) => course.name),
          onSubmit: (List<Base> selectedItems) => this.setState(() {
            selectedTags = selectedItems;
            showFilterSelector = false;
          }),
          onClosed: () => this.setState(() {
            showFilterSelector = false;
          }),
        ));
  }

  Widget _filterWidget() {
    return GestureDetector(
      onTap: () => this.setState(() {
        showFilterSelector = !showFilterSelector;
      }),
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0, top: 4),
        child: Icon(
          showFilterSelector ? Icons.filter_alt : Icons.filter_alt_outlined,
          color: OlukoColors.appBarIcon,
          size: 25,
        ),
      ),
    );
  }
}
