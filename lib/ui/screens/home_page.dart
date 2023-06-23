import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course/course_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/search_results_grid.dart';
import 'package:oluko_app/ui/components/search_suggestions.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/search_utils.dart';
import '../../routes.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User profile;
  SearchResults<Course> searchResults = SearchResults(query: '', suggestedItems: []);
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
    carouselSectionHeight = ((ScreenUtils.width(context) / _cardsToShow()) / cardsAspectRatio) + 75;
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      return BlocBuilder<CourseBloc, CourseState>(
          bloc: BlocProvider.of<CourseBloc>(context)..getByCategories(),
          builder: (context, courseState) {
            return BlocBuilder<TagBloc, TagState>(
                bloc: BlocProvider.of<TagBloc>(context)..getByCategories(),
                builder: (context, tagState) {
                  return Scaffold(
                      backgroundColor: OlukoColors.black,
                      appBar: OlukoAppBar(title: OlukoLocalizations.get(context, 'home'), showBackButton: false),
                      body: courseState is CourseSuccess && tagState is TagSuccess
                          ? WillPopScope(
                              onWillPop: () => AppNavigator.onWillPop(context),
                              child: OrientationBuilder(builder: (context, orientation) {
                                return ListView(
                                  physics: OlukoNeumorphism.listViewPhysicsEffect,
                                  addAutomaticKeepAlives: false,
                                  addRepaintBoundaries: false,
                                  shrinkWrap: true,
                                  children: [
                                    Container(
                                      height: ScreenUtils.height(context),
                                      width: ScreenUtils.width(context),
                                      child: showFilterSelector
                                          ? SearchUtils.filterSelector(
                                              tagState,
                                              onSubmit: (List<Base> selectedItems) => this.setState(() {
                                                selectedTags = selectedItems as List<Tag>;
                                                showFilterSelector = false;
                                                searchKey.currentState.updateSearchResults('');
                                              }),
                                              onClosed: () => this.setState(() {
                                                showFilterSelector = false;
                                              }),
                                            )
                                          : searchResults.query.isEmpty && selectedTags.isEmpty
                                              ? _mainPage(context, courseState)
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
        crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? searchResultsPortrait : searchResultsLandscape,
        textInput: searchResults.query,
        itemList: searchResults.searchResults);
  }

  Widget _searchSuggestions() {
    return SearchSuggestions<Course>(
        textInput: searchResults.query,
        itemList: searchResults.suggestedItems,
        onPressed: (dynamic item) => searchKey.currentState.updateSearchResults(item.name as String),
        keyNameList: searchResults.suggestedItems.map((e) => e.name).toList());
  }

  Widget _mainPage(mainContext, CourseSuccess courseState) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, left: 8, right: 8),
      child: ListView(
        physics: OlukoNeumorphism.listViewPhysicsEffect,
        children: [
          ListView.builder(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              physics: NeverScrollableScrollPhysics(),
              itemCount: courseState.coursesByCategories.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final List<Course> coursesList = courseState.coursesByCategories.values.elementAt(index);
                return CarouselSection(
                  height: carouselSectionHeight,
                  title: courseState.coursesByCategories.keys.elementAt(index).name,
                  optionLabel: OlukoLocalizations.get(context, 'viewAll'),
                  children: coursesList
                      .map((course) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              //TODO: Change to RouteEnum.courseMarketing
                              //when finish with enrolledClass
                              onTap: () =>
                                  Navigator.pushNamed(context, routeLabels[RouteEnum.enrolledClass], arguments: {'course': course, 'fromCoach': false}),
                              child: _getCourseCard(
                                  Image(
                                    image: CachedNetworkImageProvider(
                                      course.image,
                                    ),
                                    fit: BoxFit.cover,
                                    frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                                        ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 120),
                                  ),
                                  width: ScreenUtils.width(context) / (0.2 + _cardsToShow())),
                            ),
                          ))
                      .toList(),
                );
              }),
          SizedBox(
            height: 200,
          )
        ],
      ),
    );
  }

  CourseCard _getCourseCard(Image image, {double progress, double width, double height}) {
    return CourseCard(
      width: width,
      height: height,
      imageCover: image,
      progress: progress,
    );
  }

  Future<void> getProfile() async {
    final profileData = AuthRepository.getLoggedUser();
    profile = profileData ?? null;
  }

  onGoBack() {
    setState(() {});
  }
}
