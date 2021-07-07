import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
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
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/course_utils.dart';
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
                                  width: ScreenUtils.width(context),
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
                      body: courseState is CourseSuccess &&
                              tagState is TagSuccess
                          ? WillPopScope(
                              onWillPop: () => AppNavigator.onWillPop(context),
                              child: OrientationBuilder(
                                  builder: (context, orientation) {
                                return ListView(
                                  shrinkWrap: true,
                                  children: [
                                    Container(
                                      height: ScreenUtils.height(context),
                                      width: ScreenUtils.width(context),
                                      child: showFilterSelector
                                          ? CourseUtils.filterSelector(
                                              tagState,
                                              onSubmit:
                                                  (List<Base> selectedItems) =>
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
                                              ? _mainPage(courseState)
                                              : showSearchSuggestions
                                                  ? _searchSuggestions()
                                                  : _searchResults(),
                                    ),
                                  ],
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

  Widget _mainPage(CourseSuccess courseState) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, left: 8, right: 8),
      child: ListView(
        children: [
          StoriesHeader(),
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
                              onTap: () =>
                                  Navigator.pushNamed(context, '/classes'),
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

  Future<void> getProfile() async {
    final profileData = AuthRepository.getLoggedUser();
    profile = profileData != null ? profileData : null;
  }

  List<Widget> menuOptions(AuthState state) {
    List<Widget> options = [];
    //TODO: Remove this when take it to the correct place inside courses
    options.add(ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/movement-detail')
          .then((value) => onGoBack()),
      child: Text(
        "TEST",
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
          padding: EdgeInsets.symmetric(horizontal: 3),
          shadowColor: Colors.transparent,
          primary: Colors.transparent),
    ));

    options.add(ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/assessment-videos')
          .then((value) => onGoBack()),
      child: Text(
        OlukoLocalizations.of(context).find('assessments').toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 3),
          shadowColor: Colors.transparent,
          primary: Colors.transparent),
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
            padding: EdgeInsets.symmetric(horizontal: 3),
            shadowColor: Colors.transparent,
            primary: Colors.transparent),
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
            padding: EdgeInsets.symmetric(horizontal: 3),
            shadowColor: Colors.transparent,
            primary: Colors.transparent),
      ));
      options.add(ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/profile')
            .then((value) => onGoBack()),
        child: Text(
          OlukoLocalizations.of(context).find('profile').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 3),
            shadowColor: Colors.transparent,
            primary: Colors.transparent),
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
            padding: EdgeInsets.symmetric(horizontal: 3),
            shadowColor: Colors.transparent,
            primary: Colors.transparent),
      ));
      options.add(ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/log-in').then((value) => onGoBack()),
        child: Text(
          OlukoLocalizations.of(context).find('login').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 3),
            shadowColor: Colors.transparent,
            primary: Colors.transparent),
      ));
    }

    return options;
  }

  onGoBack() {
    setState(() {});
  }
}
