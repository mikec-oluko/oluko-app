import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvt_fitness/blocs/auth_bloc.dart';
import 'package:mvt_fitness/blocs/course_bloc.dart';
import 'package:mvt_fitness/blocs/tag_bloc.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/models/base.dart';
import 'package:mvt_fitness/models/course.dart';
import 'package:mvt_fitness/models/search_results.dart';
import 'package:mvt_fitness/models/tag.dart';
import 'package:mvt_fitness/ui/components/black_app_bar.dart';
import 'package:mvt_fitness/ui/components/bottom_navigation_bar.dart';
import 'package:mvt_fitness/ui/components/carousel_section.dart';
import 'package:mvt_fitness/ui/components/course_card.dart';
import 'package:mvt_fitness/ui/components/oluko_circular_progress_indicator.dart';
import 'package:mvt_fitness/ui/components/search_bar.dart';
import 'package:mvt_fitness/ui/components/search_results_grid.dart';
import 'package:mvt_fitness/ui/components/search_suggestions.dart';
import 'package:mvt_fitness/ui/components/title_body.dart';
import 'package:mvt_fitness/ui/screens/classes.dart';
import 'package:mvt_fitness/utils/app_navigator.dart';
import 'package:mvt_fitness/utils/course_utils.dart';
import 'package:mvt_fitness/utils/image_utils.dart';
import 'package:mvt_fitness/utils/oluko_localizations.dart';
import 'package:mvt_fitness/utils/screen_utils.dart';

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
  List<Tag> selectedTags = [];
  //Used to trigger AppBar Search Functions
  final searchKey = GlobalKey<SearchState>();
  //Flags to control on-screen components
  bool showSearchSuggestions = false;
  bool showFilterSelector = false;
  //Constants to display cards
  final double cardsAspectRatio = 0.69333;
  final int cardsToShowOnPortrait = 4;
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
                        ? WillPopScope(
                            onWillPop: () => AppNavigator.onWillPop(context),
                            child: OrientationBuilder(
                                builder: (context, orientation) {
                              return Container(
                                height: ScreenUtils.height(context),
                                width: ScreenUtils.width(context),
                                child: showFilterSelector
                                    ? CourseUtils.filterSelector(
                                        tagState,
                                        onSubmit: (List<Base> selectedItems) =>
                                            this.setState(() {
                                          selectedTags = selectedItems;
                                          showFilterSelector = false;
                                          searchKey.currentState
                                              .updateSearchResults('');
                                        }),
                                        onClosed: () => this.setState(() {
                                          showFilterSelector = false;
                                        }),
                                      )
                                    : searchResults.query.isEmpty &&
                                            selectedTags.isEmpty
                                        ? _mainPage(context, courseState)
                                        : showSearchSuggestions
                                            ? CourseUtils.searchSuggestions(
                                                searchResults, searchKey)
                                            : CourseUtils.searchResults(
                                                context,
                                                searchResults,
                                                cardsAspectRatio,
                                                searchResultsPortrait,
                                                searchResultsLandscape),
                              );
                            }),
                          )
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

  Widget _appBar(CourseState state) {
    return state is CourseSuccess
        ? OlukoAppBar<Course>(
            showBackButton: false,
            searchKey: searchKey,
            title: showFilterSelector
                ? OlukoLocalizations.of(context).find('filters')
                : OlukoLocalizations.of(context).find('courses'),
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
            suggestionMethod: CourseUtils.suggestionMethod,
            searchMethod: CourseUtils.searchMethod,
            searchResultItems: state.values,
            showSearchBar: true,
            whenSearchBarInitialized: (TextEditingController controller) =>
                searchBarController = controller,
          )
        : null;
  }

  Widget _mainPage(mainContext, CourseSuccess courseState) {
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
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BlocProvider<AuthBloc>(
                                            create: (context) =>
                                                BlocProvider.of<AuthBloc>(
                                                    mainContext),
                                            child: Classes(
                                                courseId:
                                                    'OYyjeSBYcumpcg2VbMXO' /*course.id*/),
                                          ))),
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
                            ),
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

  Widget _filterWidget() {
    return GestureDetector(
      onTap: () => this.setState(() {
        if (showFilterSelector == true) {
          //Clear all filters
          CourseUtils.onClearFilters(context).then((value) => value
              ? this.setState(() {
                  selectedTags.clear();
                  showFilterSelector = false;
                })
              : null);
        } else {
          //Toggle filter view
          showFilterSelector = !showFilterSelector;
        }
      }),
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0, top: 5),
        child: showFilterSelector
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    OlukoLocalizations.of(context).find('clearAll'),
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoColors.primary),
                  ),
                ],
              )
            : Icon(
                showFilterSelector || selectedTags.length > 0
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
                color: OlukoColors.appBarIcon,
                size: 25,
              ),
      ),
    );
  }
}
