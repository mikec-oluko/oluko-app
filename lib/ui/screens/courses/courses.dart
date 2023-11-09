import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/course/course_friend_recommended_bloc.dart';
import 'package:oluko_app/blocs/course/course_liked_courses_bloc.dart';
import 'package:oluko_app/blocs/course/course_subscription_bloc.dart';
import 'package:oluko_app/blocs/course/course_user_interaction_bloc.dart';
import 'package:oluko_app/blocs/course_category_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/recommendation_bloc.dart';
import 'package:oluko_app/blocs/remain_selected_tags_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/clear_all_button.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/cancel_bottom_panel.dart';
import 'package:oluko_app/ui/newDesignComponents/friends_recommended_courses.dart';
import 'package:oluko_app/ui/newDesignComponents/my_list_of_courses_home.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/search_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../routes.dart';

class Courses extends StatefulWidget {
  bool homeEnrollTocourse;
  bool firstTimeEnroll;
  bool backButtonWithFilters;
  Function showBottomTab;
  Courses({this.homeEnrollTocourse = false, this.showBottomTab, this.backButtonWithFilters = false, this.firstTimeEnroll = false, Key key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<Courses> {
  SearchResults<Course> searchResults = SearchResults(query: '', suggestedItems: []);
  double carouselSectionHeight;
  String coachId;
  TextEditingController searchBarController;
  List<Tag> selectedTags = [];
  UserResponse _currentAuthUser;
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
  final double padding = OlukoNeumorphism.isNeumorphismDesign ? 0.65 : 0.2;
  final int carSecHeigthPlus = OlukoNeumorphism.isNeumorphismDesign ? 50 : 75;
  List<Course> _courses;
  Map<CourseCategory, List<Course>> _coursesByCategories;
  PanelController panelController = PanelController();

  @override
  void initState() {
    BlocProvider.of<RemainSelectedTagsBloc>(context).set([]);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          carouselSectionHeight = CourseUtils.getCarouselSectionHeight(context);

          _currentAuthUser = authState.user;
          getCoursesData(context);
        }
        return BlocBuilder<CourseSubscriptionBloc, CourseSubscriptionState>(builder: (context, courseSubscriptionState) {
          return BlocBuilder<CourseCategoryBloc, CourseCategoryState>(builder: (context, courseCategoryState) {
            if (courseSubscriptionState is CourseSubscriptionSuccess && courseCategoryState is CourseCategorySubscriptionSuccess) {
              _courses = courseSubscriptionState.values;
              _coursesByCategories = CourseUtils.mapCoursesByCategories(_courses, courseCategoryState.values);
              return BlocBuilder<TagBloc, TagState>(
                  bloc: BlocProvider.of<TagBloc>(context)..getByCategories(),
                  builder: (context, tagState) {
                    return SlidingUpPanel(
                        controller: panelController,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        maxHeight: 250,
                        minHeight: 0,
                        panel: CancelBottomPanel(
                            title: OlukoLocalizations.get(context, 'cancelMssg'),
                            text: OlukoLocalizations.get(context, 'cancelTxt'),
                            textButtonTxt: OlukoLocalizations.get(context, 'no'),
                            primaryButtonTxt: OlukoLocalizations.get(context, 'yes'),
                            primaryButtonAction: cancelAction,
                            textButtonAction: () => panelController.close()),
                        body: Container(
                            color: OlukoNeumorphismColors.appBackgroundColor,
                            child: Scaffold(
                                extendBody: true,
                                backgroundColor: OlukoNeumorphismColors.appBackgroundColor,
                                appBar: _appBar(widget.homeEnrollTocourse ?? false),
                                body: _courseWidget(context, tagState))));
                  });
            } else {
              return const SizedBox.shrink();
            }
          });
        });
      },
    );
  }

  void getCoursesData(BuildContext context) {
    BlocProvider.of<CourseSubscriptionBloc>(context).getStream();
    BlocProvider.of<CourseCategoryBloc>(context).getStream();
    BlocProvider.of<CourseRecommendedByFriendBloc>(context).getStreamOfCoursesRecommendedByFriends(userId: _currentAuthUser.id);
    BlocProvider.of<LikedCoursesBloc>(context).getStreamOfLikedCourses(userId: _currentAuthUser.id);
  }

  int _cardsToShow() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return cardsToShowOnPortrait;
    } else {
      return cardsToShowOnLandscape;
    }
  }

  Widget _courseWidget(BuildContext context, TagState tagState) {
    if (tagState is TagSuccess) {
      return OrientationBuilder(builder: (context, orientation) {
        return Container(
          color: OlukoNeumorphismColors.appBackgroundColor,
          height: ScreenUtils.height(context),
          width: ScreenUtils.width(context),
          child: showFilterSelector
              ? SearchUtils.filterSelector(tagState,
                  onSubmit: (List<Base> selectedItems) => setState(() {
                        selectedTags = selectedItems as List<Tag>;
                        showFilterSelector = false;
                        BlocProvider.of<RemainSelectedTagsBloc>(context).set(selectedTags);
                        searchKey.currentState.updateSearchResults('', selectedTags: selectedTags);
                      }),
                  onClosed: () => setState(() {
                        showFilterSelector = false;
                      }),
                  showBottomTab: widget.showBottomTab)
              : searchResults.query.isEmpty && selectedTags.isEmpty
                  ? _mainPage(context)
                  : showSearchSuggestions
                      ? SearchUtils.searchSuggestions(searchResults, searchKey, context)
                      : SearchUtils.searchCourseResults(context, searchResults, cardsAspectRatio, searchResultsPortrait, searchResultsLandscape),
        );
      });
    }

    // this return will handle this states: TagLoading TagFailure CourseLoading CourseFailure
    return Container(color: OlukoNeumorphismColors.appBackgroundColor, child: OlukoCircularProgressIndicator());
  }

  PreferredSizeWidget _appBar(bool goBack) {
    return OlukoAppBar<Course>(
      showBottomTab: widget.showBottomTab,
      showTitle: true,
      searchKey: searchKey,
      showBackButton: goBack,
      backButtonWithFilters: widget.backButtonWithFilters,
      showActions: widget.homeEnrollTocourse,
      title: OlukoLocalizations.get(
          context,
          searchResults.query.isNotEmpty || selectedTags.isNotEmpty
              ? 'filtersResult'
              : showFilterSelector
                  ? 'filters'
                  : 'courses'),
      actions: widget.firstTimeEnroll ? [] : [_filterWidget()],
      onPressed: () => Navigator.pushNamed(context, routeLabels[RouteEnum.root]),
      onSearchSubmit: (SearchResults<Course> results) => setState(() {
        showSearchSuggestions = false;
        searchResults = results;
      }),
      onSearchResults: (SearchResults results) => setState(() {
        showSearchSuggestions = true;
        searchResults = SearchResults<Course>(query: results.query, suggestedItems: List<Course>.from(results.searchResults));
      }),
      suggestionMethod: SearchUtils.suggestionMethodForCourses,
      searchMethod: SearchUtils.searchCoursesMethod,
      searchResultItems: _courses,
      showSearchBar: true,
      whenSearchBarInitialized: (TextEditingController controller) => searchBarController = controller,
      actionButton: () {
        showFilterSelector = false;
        cancelAction();
      },
    );
  }

  Widget _mainPage(mainContext) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 8, right: 8),
      child: ListView(
        physics: OlukoNeumorphism.listViewPhysicsEffect,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        padding: EdgeInsets.only(bottom: ScreenUtils.height(context) * 0.10),
        children: [_activeCoursesSection(), _myListSection(), _getFriendsRecommendations(), _courseCategoriesSections()],
      ),
    );
  }

  ListView _courseCategoriesSections() {
    return ListView.builder(
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _coursesByCategories.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final List<Course> coursesList = _coursesByCategories.values.elementAt(index);
          if (coursesList.isEmpty) {
            return nil;
          } else {
            return CarouselSection(
              onOptionTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.viewAll],
                  arguments: {'courses': coursesList, 'title': _coursesByCategories.keys.elementAt(index).name}),
              height: carouselSectionHeight,
              title: _coursesByCategories.keys.elementAt(index).name,
              optionLabel: OlukoLocalizations.get(context, 'viewAll'),
              children: coursesList.map((course) => getCourseCategoriesCards(context, course)).toList(),
            );
          }
        });
  }

  Padding getCourseCategoriesCards(BuildContext context, Course course) {
    return Padding(
      padding: const EdgeInsets.only(right: OlukoNeumorphism.isNeumorphismDesign ? 12 : 8.0),
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<CourseUserInteractionBloc>(context).isCourseLiked(courseId: course.id, userId: _currentAuthUser.id);
          Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
              arguments: {'course': course, 'fromCoach': false, 'isCoachRecommendation': false});
        },
        child: _getCourseCard(CourseUtils.generateImageCourse(course.image, context), width: ScreenUtils.width(context) / (padding + _cardsToShow())),
      ),
    );
  }

  CourseCard _getCourseCard(Widget image,
      {double progress, double width, double height, List<UserResponse> userRecommendations, bool friendRecommended = false}) {
    return CourseCard(
        width: width, height: height, imageCover: image, progress: progress, userRecommendations: userRecommendations, friendRecommended: friendRecommended);
  }

  Widget _filterWidget() {
    return GestureDetector(
      onTap: () {
        if (showFilterSelector == true) {
          //Clear all filters
          //CourseUtils.onClearFilters(context).then((value) => value ? cancelAction() : null);
          panelController.open();
        } else {
          setState(() {
            widget.showBottomTab();
            showFilterSelector = !showFilterSelector;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0, top: 5),
        child: showFilterSelector
            ? const ClearAllButton()
            : OlukoNeumorphism.isNeumorphismDesign
                ? OlukoNeumorphicCircleButton(
                    customIcon: Icon(
                      showFilterSelector || selectedTags.isNotEmpty ? Icons.filter_alt : Icons.filter_alt_outlined,
                      color: OlukoColors.grayColor,
                      size: 25,
                    ),
                    onPressed: () => setState(() {
                      if (showFilterSelector == true) {
                        //Clear all filters
                        //CourseUtils.onClearFilters(context).then((value) => value ? cancelAction() : null);
                        panelController.open();
                      } else {
                        //Toggle filter view
                        showFilterSelector = !showFilterSelector;
                        widget.showBottomTab();
                      }
                    }),
                  )
                : Icon(
                    showFilterSelector || selectedTags.isNotEmpty ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color: OlukoColors.appBarIcon,
                    size: 25,
                  ),
      ),
    );
  }

  void cancelAction() {
    setState(() {
      selectedTags.clear();
      BlocProvider.of<RemainSelectedTagsBloc>(context).set([]);
    });
    panelController.close();
  }

  Widget _activeCoursesSection() {
    List<Course> enrolledCourses = [];
    return BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
        bloc: BlocProvider.of<CourseEnrollmentListStreamBloc>(context)..getStream(_currentAuthUser.id),
        builder: (context, courseEnrollmentState) {
          if (_checkCourseEnrollmentsState(courseEnrollmentState)) {
            return CarouselSection(
              title: OlukoLocalizations.get(context, 'activeCourses'),
              height: carouselSectionHeight + 10,
              optionLabel: OlukoLocalizations.get(context, 'viewAll'),
              onOptionTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.viewAll],
                  arguments: {'courses': enrolledCourses, 'title': OlukoLocalizations.get(context, 'activeCourses')}),
              children: _getActiveCoursesList(courseEnrollmentState, enrolledCourses),
            );
          } else {
            return nil;
          }
        });
  }

  Widget _myListSection() {
    return Container(child: BlocBuilder<LikedCoursesBloc, LikedCourseState>(
      builder: (context, state) {
        Map<CourseCategory, List<Course>> myListOfCourses = {};
        if (state is CourseLikedListSuccess) {
          CourseCategory _myListCategory = state.myLikedCourses;
          if (_myListCategory != null) {
            myListOfCourses = CourseUtils.mapCoursesByCategories(_courses, [_myListCategory]);
          }
        }
        return myListOfCourses != null && myListOfCourses.values.toList().isNotEmpty
            ? Container(
                child: MyListOfCourses(
                  myListOfCourses: myListOfCourses,
                  beforeNavigation: (String courseId) =>
                      BlocProvider.of<CourseUserInteractionBloc>(context).isCourseLiked(courseId: courseId, userId: _currentAuthUser.id),
                ),
              )
            : const SizedBox.shrink();
      },
    ));
  }

  Widget _getFriendsRecommendations() {
    return Container(child: BlocBuilder<CourseRecommendedByFriendBloc, CourseRecommendedByFriendState>(
      builder: (context, state) {
        List<Map<String, List<UserResponse>>> _coursesRecommendedMap = [];
        if (state is CourseRecommendedByFriendSuccess) {
          _coursesRecommendedMap = state.recommendedCourses;
        }
        return _coursesRecommendedMap.isNotEmpty
            ? FriendsRecommendedCourses(listOfCoursesRecommended: _coursesRecommendedMap, courses: _courses)
            : const SizedBox.shrink();
      },
    ));
  }

  List<Widget> _getCoachRecommendedCoursesList(RecommendationState recommendationState) {
    if (recommendationState is RecommendationSuccess && _checkRecommendationState(recommendationState)) {
      return recommendationState.recommendationsByUsers.entries.map((MapEntry<String, List<UserResponse>> courseEntry) {
        var courseList = _courses.where((element) => element.id == courseEntry.key).toList();

        if (courseList.isNotEmpty) {
          final course = courseList.first;
          return Padding(
            padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(vertical: 10, horizontal: 5) : const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                BlocProvider.of<CourseUserInteractionBloc>(context).isCourseLiked(courseId: course.id, userId: _currentAuthUser.id);
                Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing], arguments: {
                  'course': course,
                  'fromCoach': false,
                  'isCoachRecommendation': coachId != null ? courseEntry.value.first.id == coachId : false
                });
              },
              child: _getCourseCard(CourseUtils.generateImageCourse(course.image, context),
                  width: ScreenUtils.width(context) / (padding + _cardsToShow()), userRecommendations: courseEntry.value),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }).toList();
    } else {
      return [];
    }
  }

  bool _checkRecommendationState(RecommendationState recommendationState) {
    return recommendationState is RecommendationSuccess &&
        (recommendationState.recommendations.isNotEmpty && recommendationState.recommendationsByUsers.entries.isNotEmpty);
  }

  bool _checkCourseEnrollmentsState(CourseEnrollmentListStreamState courseEnrollmentState) =>
      courseEnrollmentState is CourseEnrollmentsByUserStreamSuccess && (courseEnrollmentState.courseEnrollments.isNotEmpty);

  List<Widget> _getActiveCoursesList(CourseEnrollmentListStreamState courseEnrollmentState, List<Course> enrolledCourses) {
    if (courseEnrollmentState is CourseEnrollmentsByUserStreamSuccess && _checkCourseEnrollmentsState(courseEnrollmentState)) {
      return courseEnrollmentState.courseEnrollments.map((CourseEnrollment courseEnrollment) {
        final activeCourseList = _courses.where((enrolledCourse) => enrolledCourse.id == courseEnrollment.course.id).toList();
        Course course;
        int courseIndex = courseEnrollmentState.courseEnrollments.indexOf(courseEnrollment);
        if (activeCourseList.isNotEmpty) {
          course = activeCourseList[0];
          if (!enrolledCourses.contains(course)) {
            enrolledCourses.add(course);
          }
          return Padding(
            padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.only(right: 12, bottom: 8, top: 8) : const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                BlocProvider.of<CourseUserInteractionBloc>(context).isCourseLiked(courseId: course.id, userId: _currentAuthUser.id);
                Navigator.pushNamed(context, routeLabels[RouteEnum.enrolledCourse], arguments: {
                  'course': course,
                  'fromCoach': false,
                  'isCoachRecommendation': false,
                  'courseEnrollment': courseEnrollment,
                  'courseIndex': courseIndex
                });
              },
              child: _getCourseCard(
                CourseUtils.generateImageCourse(course.image, context),
                progress: courseEnrollment.completion,
                width: ScreenUtils.width(context) / (padding + _cardsToShow()),
              ),
            ),
          );
        } else {
          return nil;
        }
      }).toList();
    } else {
      return [];
    }
  }
}
