import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/elements/card_carousel.dart';
import 'package:oluko_app/elements/gallery_carousel.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/filter_selector.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/search_results_grid.dart';
import 'package:oluko_app/ui/components/search_suggestions.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User profile;
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
  final int cardsToShowOnPortrait = 3;
  final int cardsToShowOnLandscape = 5;
  final int searchResultsPortrait = 2;
  final int searchResultsLandscape = 5;

  @override
  Widget build(BuildContext context) {
    carouselSectionHeight =
        ((ScreenUtils.width(context) / _cardsToShow()) / cardsAspectRatio) + 75;
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      return BlocBuilder<CourseBloc, CourseState>(
          bloc: BlocProvider.of<CourseBloc>(context)..getByCategories(),
          builder: (context, courseState) {
            return BlocBuilder<TagBloc, TagState>(
                bloc: BlocProvider.of<TagBloc>(context)..getByCategories(),
                builder: (context, tagState) {
                  return Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        title: Text(widget.title,
                            style: TextStyle(color: Colors.white)),
                        actions: [
                          Stack(
                            children: [
                              Container(
                                  width: ScreenUtils.width(context) * 1,
                                  child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: menuOptions(authState))),
                              Positioned(
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                      stops: [0, 1],
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                      colors: [
                                        Colors.black,
                                        Colors.transparent,
                                      ],
                                    )),
                                    width: ScreenUtils.width(context) / 10,
                                    height: kToolbarHeight,
                                  )),
                            ],
                          )
                        ],
                        backgroundColor: Colors.black,
                        actionsIconTheme: IconThemeData(color: Colors.white),
                        iconTheme: IconThemeData(color: Colors.white),
                      ),
                      bottomNavigationBar: OlukoBottomNavigationBar(),
                      body:
                          courseState is CourseSuccess && tagState is TagSuccess
                              ? WillPopScope(
                                  onWillPop: _onWillPop,
                                  child: OrientationBuilder(
                                      builder: (context, orientation) {
                                    return Container(
                                      height: ScreenUtils.height(context),
                                      width: ScreenUtils.width(context),
                                      child: showFilterSelector
                                          ? _filterSelector(tagState)
                                          : searchResults.query.isEmpty &&
                                                  selectedTags.isEmpty
                                              ? _mainPage(courseState)
                                              : showSearchSuggestions
                                                  ? _searchSuggestions()
                                                  : _searchResults(),
                                    );
                                  }),
                                )
                              : OlukoCircularProgressIndicator());
                });
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
    List<Course> resultsWithoutFilters = collection
        .where(
            (course) => course.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    List<Course> filteredResults = resultsWithoutFilters.where((Course course) {
      final List<String> courseTagIds = course.tags != null
          ? course.tags.map((e) => e.objectId).toList()
          : [];
      final List<String> selectedTagIds =
          selectedTags.map((e) => e.id).toList();
      //Return true if no filters are selected
      if (selectedTags.isEmpty) {
        return true;
      }
      //Check if this course match with the current tag filters.
      bool tagMatch = false;
      courseTagIds.forEach((tagId) {
        if (selectedTagIds.contains(tagId)) {
          tagMatch = true;
        }
      });
      return tagMatch;
    }).toList();
    return filteredResults;
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

  Widget _filterSelector(TagSuccess state) {
    return Padding(
        padding: EdgeInsets.only(top: 15.0, left: 8, right: 8),
        child: FilterSelector<Tag>(
          itemList: Map.fromIterable(state.tagsByCategories.entries,
              key: (entry) => entry.key.name,
              value: (entry) => Map.fromIterable(entry.value,
                  key: (tag) => tag, value: (tag) => tag.name)),
          selectedTags: selectedTags,
          onSubmit: (List<Base> selectedItems) => this.setState(() {
            selectedTags = selectedItems;
            showFilterSelector = false;
            searchKey.currentState.updateSearchResults('');
          }),
          onClosed: () => this.setState(() {
            showFilterSelector = false;
          }),
        ));
  }

  Widget _filterWidget() {
    return GestureDetector(
      onTap: () => this.setState(() {
        if (showFilterSelector == true) {
          //Clear all filters
          _onClearFilters().then((value) => value
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

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: Colors.black,
            title: TitleBody('Are you Sure?'),
            content: new Text('Do you want to exit Oluko MVT?',
                style: OlukoFonts.olukoBigFont()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> _onClearFilters() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: Colors.grey.shade900,
            content: Container(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Would you like to cancel?',
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoBigFont()),
                  ),
                  Text(
                    'Cancelling would remove all the selected filters, please confirm the action.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              Container(
                width: ScreenUtils.width(context),
                child: Row(
                  children: [
                    OlukoPrimaryButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      title: 'No',
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    OlukoOutlinedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        title: 'Yes')
                  ],
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> getProfile() async {
    final profileData = await AuthRepository.getLoggedUser();
    profile = profileData != null ? profileData : null;
  }

  List<Widget> menuOptions(AuthState state) {
    List<Widget> options = [];
    //TODO: Remove this when take it to the correct place inside courses
    options.add(ElevatedButton(
      onPressed: () =>
          Navigator.pushNamed(context, '/classes').then((value) => onGoBack()),
      child: Text(
        OlukoLocalizations.of(context).find('classes').toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent, primary: Colors.transparent),
    ));

    options.add(ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/app-plans')
          .then((value) => onGoBack()),
      child: Text(
        OlukoLocalizations.of(context).find('plans').toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent, primary: Colors.transparent),
    ));

    options.add(ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/assessment-videos')
          .then((value) => onGoBack()),
      child: Text(
        OlukoLocalizations.of(context).find('assessments').toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent, primary: Colors.transparent),
    ));

    if (state is AuthSuccess) {
      options.add(ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/videos').then((value) => onGoBack()),
        child: Text(
          OlukoLocalizations.of(context).find('videos').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
      options.add(ElevatedButton(
        onPressed: () {
          BlocProvider.of<AuthBloc>(context).logout(context);
          AppMessages.showSnackbar(context, 'Logged out.');
          setState(() {});
        },
        child: Text(
          OlukoLocalizations.of(context).find('logout').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
      options.add(ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/profile')
            .then((value) => onGoBack()),
        child: Text(
          OlukoLocalizations.of(context).find('profile').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
    } else {
      options.add(ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/sign-up')
            .then((value) => onGoBack()),
        child: Text(
          OlukoLocalizations.of(context).find('signUp').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
      options.add(ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/log-in').then((value) => onGoBack()),
        child: Text(
          OlukoLocalizations.of(context).find('login').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
    }

    return options;
  }

  onGoBack() {
    setState(() {});
  }
}
