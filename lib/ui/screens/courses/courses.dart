import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/favorite_bloc.dart';
import 'package:oluko_app/blocs/recommendation_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/favorite.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import '../../../routes.dart';

class Courses extends StatefulWidget {
  bool homeEnrollTocourse;
  Courses({this.homeEnrollTocourse, Key key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<Courses> {
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
  final int cardsToShowOnPortrait = 3;
  final int cardsToShowOnLandscape = 4;
  final int searchResultsPortrait = 3;
  final int searchResultsLandscape = 5;
  //TODO Make Dynamic
  List<String> userRecommendationsAvatarUrls = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEMWzdlSputkYso9dJb4VY5VEWQunXGBJMgGys7BLC4MzPQp6yfLURe-9nEdGrcK6Jasc&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTF-rBV5pmJhYA8QbjpPcx6s9SywnXGbvsaxWyFi47oDf9JuL4GruKBY5zl2tM4tdgYdQ0&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRF1L_s4YJh7RHSIag8CxT0LTuJQo-XQnTJkVApDXar4b0A57U_TnAMrK_l4Fd_Nzp65Bg&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRF1L_s4YJh7RHSIag8CxT0LTuJQo-XQnTJkVApDXar4b0A57U_TnAMrK_l4Fd_Nzp65Bg&usqp=CAU'
  ];

  String defaultAvatar =
      'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/default-avatar.png?alt=media&token=d293c16b-1d61-4123-8cbe-6ed6c7601783';

  @override
  Widget build(BuildContext context) {
    carouselSectionHeight = ((ScreenUtils.width(context) / _cardsToShow()) / cardsAspectRatio) + 75;
    return BlocBuilder<CourseBloc, CourseState>(
        bloc: BlocProvider.of<CourseBloc>(context)..getByCategories(),
        builder: (context, courseState) {
          return BlocBuilder<TagBloc, TagState>(
              bloc: BlocProvider.of<TagBloc>(context)..getByCategories(),
              builder: (context, tagState) {
                return Scaffold(
                    backgroundColor: Colors.black,
                    appBar: _appBar(courseState, widget.homeEnrollTocourse ?? false),
                    body: _courseWidget(context, tagState, courseState));
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

  Widget _courseWidget(BuildContext context, TagState tagState, CourseState courseState) {
    if (courseState is CourseSuccess) {
      if (tagState is TagSuccess) {
        return WillPopScope(
          onWillPop: () => AppNavigator.onWillPop(context),
          child: OrientationBuilder(builder: (context, orientation) {
            return Container(
              height: ScreenUtils.height(context),
              width: ScreenUtils.width(context),
              child: showFilterSelector
                  ? CourseUtils.filterSelector(
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
                          ? CourseUtils.searchSuggestions(searchResults, searchKey)
                          : CourseUtils.searchResults(
                              context, searchResults, cardsAspectRatio, searchResultsPortrait, searchResultsLandscape),
            );
          }),
        );
      }
    }

    // this return will handle this states: TagLoading TagFailure CourseLoading CourseFailure
    return OlukoCircularProgressIndicator();
  }

  PreferredSizeWidget _appBar(CourseState state, bool goBack) {
    return state is CourseSuccess
        ? OlukoAppBar<Course>(
            showBackButton: goBack,
            searchKey: searchKey,
            title: OlukoLocalizations.get(context, showFilterSelector ? 'filters' : 'courses'),
            actions: [_filterWidget()],
            onPressed: () => Navigator.pushNamed(context, routeLabels[RouteEnum.root]),
            onSearchSubmit: (SearchResults<Course> results) => this.setState(() {
              showSearchSuggestions = false;
              searchResults = results;
            }),
            onSearchResults: (SearchResults results) => this.setState(() {
              showSearchSuggestions = true;
              searchResults = SearchResults<Course>(
                  query: results.query, suggestedItems: List<Course>.from(results.suggestedItems));
            }),
            suggestionMethod: CourseUtils.suggestionMethod,
            searchMethod: CourseUtils.searchMethod,
            searchResultItems: state.values,
            showSearchBar: true,
            whenSearchBarInitialized: (TextEditingController controller) => searchBarController = controller,
          )
        : null;
  }

  Widget _mainPage(mainContext, CourseSuccess courseState) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 8, right: 8),
      child: ListView(
        children: [
          _activeCoursesSection(courseState),
          _myListSection(courseState),
          _friendsRecommendedSection(courseState),
          _courseCategoriesSections(courseState)
        ],
      ),
    );
  }

  ListView _courseCategoriesSections(CourseSuccess courseState) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: courseState.coursesByCategories.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final List<Course> coursesList = courseState.coursesByCategories.values.elementAt(index);
          if (coursesList.isEmpty) {
            return nil;
          } else {
            return CarouselSection(
              onOptionTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.viewAll], arguments: {
                'courses': coursesList,
                'title': courseState.coursesByCategories.keys.elementAt(index).name
              }),
              height: carouselSectionHeight,
              title: courseState.coursesByCategories.keys.elementAt(index).name,
              optionLabel: OlukoLocalizations.get(context, 'viewAll'),
              children: coursesList
                  .map((course) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                              arguments: {'course': course, 'fromCoach': false}),
                          child: _getCourseCard(_generateImageCourse(course.image),
                              width: ScreenUtils.width(context) / (0.2 + _cardsToShow())),
                        ),
                      ))
                  .toList(),
            );
          }
        });
  }

  CourseCard _getCourseCard(Image image,
      {double progress, double width, double height, List<String> userRecommendationsAvatarUrls}) {
    return CourseCard(
        width: width,
        height: height,
        imageCover: image,
        progress: progress,
        userRecommendationsAvatarUrls: userRecommendationsAvatarUrls);
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
                    OlukoLocalizations.get(context, 'clearAll'),
                    style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary),
                  ),
                ],
              )
            : Icon(
                showFilterSelector || selectedTags.isNotEmpty ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: OlukoColors.appBarIcon,
                size: 25,
              ),
      ),
    );
  }

  Widget _friendsRecommendedSection(courseState) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        AuthSuccess authSuccess = authState;
        return BlocBuilder<RecommendationBloc, RecommendationState>(
            bloc: BlocProvider.of<RecommendationBloc>(context)..getRecommendedCoursesByUser(authSuccess.user.id),
            builder: (context, recommendationState) {
              return recommendationState is RecommendationSuccess &&
                      courseState is CourseSuccess &&
                      recommendationState.recommendations.isNotEmpty &&
                      recommendationState.recommendationsByUsers.entries.length > 0
                  ? CarouselSection(
                      title: OlukoLocalizations.get(context, 'friendsRecommended'),
                      height: carouselSectionHeight + 10,
                      children: recommendationState.recommendationsByUsers.entries
                          .map((MapEntry<String, List<UserResponse>> courseEntry) {
                        var courseList = courseState.values.where((element) => element.id == courseEntry.key).toList();
                        if (courseList.isNotEmpty) {
                          final course = courseList[0];

                          final List<String> userRecommendationAvatars =
                              courseEntry.value.map((user) => user.avatar ?? defaultAvatar).toList();

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                                  arguments: {'course': course, 'fromCoach': false}),
                              child: _getCourseCard(_generateImageCourse(course.image),
                                  width: ScreenUtils.width(context) / (0.2 + _cardsToShow()),
                                  userRecommendationsAvatarUrls: userRecommendationAvatars),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }).toList(),
                    )
                  : SizedBox();
            });
      } else {
        return SizedBox();
      }
    });
  }

  Widget _activeCoursesSection(courseState) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        AuthSuccess authSuccess = authState;
        return BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
            bloc: BlocProvider.of<CourseEnrollmentListBloc>(context)
              ..getCourseEnrollmentsByUser(authSuccess.user.id ?? authSuccess.user.firebaseId),
            builder: (context, courseEnrollmentState) {
              if (courseEnrollmentState is CourseEnrollmentsByUserSuccess &&
                  courseState is CourseSuccess &&
                  courseEnrollmentState.courseEnrollments.isNotEmpty) {
                return CarouselSection(
                  title: OlukoLocalizations.get(context, 'activeCourses'),
                  height: carouselSectionHeight + 10,
                  children: courseEnrollmentState.courseEnrollments.map((CourseEnrollment courseEnrollment) {
                    final activeCourseList =
                        courseState.values.where((element) => element.id == courseEnrollment.course.id).toList();
                    Course course;
                    if (activeCourseList.isNotEmpty) {
                      course = activeCourseList[0];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                              arguments: {'course': course, 'fromCoach': false}),
                          child: _getCourseCard(
                            _generateImageCourse(course.image),
                            progress: courseEnrollment.completion,
                            width: ScreenUtils.width(context) / (0.2 + _cardsToShow()),
                          ),
                        ),
                      );
                    } else {
                      return nil;
                    }
                  }).toList(),
                );
              } else {
                return nil;
              }
            });
      } else {
        return SizedBox();
      }
    });
  }

  Widget _myListSection(courseState) {
    return Container(
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        return authState is AuthSuccess
            ? BlocBuilder<FavoriteBloc, FavoriteState>(
                bloc: BlocProvider.of<FavoriteBloc>(context)..getByUser(authState.user.id),
                builder: (context, favoriteState) {
                  return favoriteState is FavoriteSuccess &&
                          courseState is CourseSuccess &&
                          favoriteState.favorites.length > 0
                      ? CarouselSection(
                          title: OlukoLocalizations.get(context, 'myList'),
                          height: carouselSectionHeight,
                          children: favoriteState.favorites.map((Favorite favorite) {
                            Course favoriteCourse =
                                courseState.values.where((course) => course.id == favorite.course.id).toList()[0];
                            return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                                      arguments: {'course': favoriteCourse, 'fromCoach': false}),
                                  child: _getCourseCard(
                                    _generateImageCourse(favoriteCourse.image),
                                    width: ScreenUtils.width(context) / (0.2 + _cardsToShow()),
                                  ),
                                ));
                          }).toList(),
                        )
                      : nil;
                })
            : nil;
      }),
    );
  }

  Image _generateImageCourse(String imageUrl) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
            ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 120),
      );
    }
    return Image.asset("assets/courses/course_sample_7.png");
    //TODO: fill space with default image or message
  }
}
