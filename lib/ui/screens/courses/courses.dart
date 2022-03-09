import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/course/course_subscrption_bloc.dart';
import 'package:oluko_app/blocs/course_category_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/favorite_bloc.dart';
import 'package:oluko_app/blocs/recommendation_bloc.dart';
import 'package:oluko_app/blocs/selected_tags_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/favorite.dart';
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
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../routes.dart';

class Courses extends StatefulWidget {
  bool homeEnrollTocourse;
  Function showBottomTab;
  Courses({this.homeEnrollTocourse, this.showBottomTab, Key key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<Courses> {
  SearchResults<Course> searchResults = SearchResults(query: '', suggestedItems: []);
  double carouselSectionHeight;
  String coachId;
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
  final double padding = OlukoNeumorphism.isNeumorphismDesign ? 0.65 : 0.2;
  final int carSecHeigthPlus = OlukoNeumorphism.isNeumorphismDesign ? 50 : 75;
  //TODO Make Dynamic
  List<String> userRecommendationsAvatarUrls = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEMWzdlSputkYso9dJb4VY5VEWQunXGBJMgGys7BLC4MzPQp6yfLURe-9nEdGrcK6Jasc&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTF-rBV5pmJhYA8QbjpPcx6s9SywnXGbvsaxWyFi47oDf9JuL4GruKBY5zl2tM4tdgYdQ0&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRF1L_s4YJh7RHSIag8CxT0LTuJQo-XQnTJkVApDXar4b0A57U_TnAMrK_l4Fd_Nzp65Bg&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRF1L_s4YJh7RHSIag8CxT0LTuJQo-XQnTJkVApDXar4b0A57U_TnAMrK_l4Fd_Nzp65Bg&usqp=CAU'
  ];

  String defaultAvatar =
      'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/default-avatar.png?alt=media&token=d293c16b-1d61-4123-8cbe-6ed6c7601783';

  List<Course> _courses;
  Map<CourseCategory, List<Course>> _coursesByCategories;

  PanelController panelController = PanelController();



  @override
  Widget build(BuildContext context) {
    carouselSectionHeight = ((ScreenUtils.width(context) / _cardsToShow()) / cardsAspectRatio) + carSecHeigthPlus;
    BlocProvider.of<CourseSubscriptionBloc>(context).getStream();
    BlocProvider.of<CourseCategoryBloc>(context).getStream();
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
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                        color: Colors.black,
                        child: Scaffold(
                            backgroundColor: Colors.black,
                            appBar: _appBar(widget.homeEnrollTocourse ?? false),
                            body: _courseWidget(context, tagState))));
              });
        } else {
          return SizedBox();
        }
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

  Widget _courseWidget(BuildContext context, TagState tagState) {
    if (tagState is TagSuccess) {
      return WillPopScope(
        onWillPop: () => AppNavigator.onWillPop(context),
        child: OrientationBuilder(builder: (context, orientation) {
          return Container(
            color: OlukoNeumorphismColors.appBackgroundColor,
            height: ScreenUtils.height(context),
            width: ScreenUtils.width(context),
            child: showFilterSelector
                ? CourseUtils.filterSelector(tagState,
                    onSubmit: (List<Base> selectedItems) => setState(() {
                          selectedTags = selectedItems as List<Tag>;
                          showFilterSelector = false;
                          searchKey.currentState.updateSearchResults('', selectedTags: selectedTags);
                        }),
                    onClosed: () => this.setState(() {
                          showFilterSelector = false;
                        }),
                    showBottomTab: widget.showBottomTab)
                : searchResults.query.isEmpty && selectedTags.isEmpty
                    ? _mainPage(context)
                    : showSearchSuggestions
                        ? CourseUtils.searchSuggestions(searchResults, searchKey)
                        : CourseUtils.searchResults(
                            context, searchResults, cardsAspectRatio, searchResultsPortrait, searchResultsLandscape),
          );
        }),
      );
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
      title: OlukoLocalizations.get(context, showFilterSelector ? 'filters' : 'courses'),
      actions: [_filterWidget()],
      onPressed: () => Navigator.pushNamed(context, routeLabels[RouteEnum.root]),
      onSearchSubmit: (SearchResults<Course> results) => this.setState(() {
        showSearchSuggestions = false;
        searchResults = results;
      }),
      onSearchResults: (SearchResults results) => this.setState(() {
        showSearchSuggestions = true;
        searchResults = SearchResults<Course>(query: results.query, suggestedItems: List<Course>.from(results.suggestedItems));
      }),
      suggestionMethod: CourseUtils.suggestionMethod,
      searchMethod: CourseUtils.searchMethod,
      searchResultItems: _courses,
      showSearchBar: true,
      whenSearchBarInitialized: (TextEditingController controller) => searchBarController = controller,
      actionButton: () => this.setState(() {
        showFilterSelector = false;
      }),
    );
  }

  Widget _mainPage(mainContext) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 8, right: 8),
      child: ListView(
        children: [_activeCoursesSection(), _myListSection(), _friendsRecommendedSection(), _courseCategoriesSections()],
      ),
    );
  }

  ListView _courseCategoriesSections() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
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
              children: coursesList.map((course) => getcurseCategoriesCards(context, course)).toList(),
            );
          }
        });
  }

  Padding getcurseCategoriesCards(BuildContext context, Course course) {
    return Padding(
      padding: const EdgeInsets.only(right: OlukoNeumorphism.isNeumorphismDesign ? 12 : 8.0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
            arguments: {'course': course, 'fromCoach': false, 'isCoachRecommendation': false}),
        child: _getCourseCard(_generateImageCourse(course.image), width: ScreenUtils.width(context) / (padding + _cardsToShow())),
      ),
    );
  }

  CourseCard _getCourseCard(Image image, {double progress, double width, double height, List<String> userRecommendationsAvatarUrls}) {
    return CourseCard(
        width: width, height: height, imageCover: image, progress: progress, userRecommendationsAvatarUrls: userRecommendationsAvatarUrls);
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
            //Toggle filter view
            showFilterSelector = !showFilterSelector;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0, top: 5),
        child: showFilterSelector
            ? ClearAllButton()
            : OlukoNeumorphism.isNeumorphismDesign
                ? OlukoNeumorphicCircleButton(
                    customIcon: Icon(
                      showFilterSelector || selectedTags.isNotEmpty ? Icons.filter_alt : Icons.filter_alt_outlined,
                      color: OlukoColors.grayColor,
                      size: 25,
                    ),
                    onPressed: () => this.setState(() {
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
    });
    panelController.close();
  }

//TODO: CHECK COACH ON ENROLL
  Widget _friendsRecommendedSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          AuthSuccess authSuccess = authState;

          return BlocListener<CoachAssignmentBloc, CoachAssignmentState>(
            listenWhen: (CoachAssignmentState previous, CoachAssignmentState current) {
              return current is CoachAssignmentResponse;
            },
            bloc: BlocProvider.of<CoachAssignmentBloc>(context)..getCoachAssignmentStatus(authSuccess.user.id),
            listener: (BuildContext context, coachAssignmentState) {
              if (coachAssignmentState is CoachAssignmentResponse) {
                coachId =
                    coachAssignmentState.coachAssignmentResponse != null ? coachAssignmentState.coachAssignmentResponse.coachId : null;
              }
            },
            child: BlocBuilder<RecommendationBloc, RecommendationState>(
                bloc: BlocProvider.of<RecommendationBloc>(context)..getRecommendedCoursesByUser(authSuccess.user.id),
                builder: (context, recommendationState) {
                  return recommendationState is RecommendationSuccess &&
                          recommendationState.recommendations.isNotEmpty &&
                          recommendationState.recommendationsByUsers.entries.isNotEmpty
                      ? CarouselSection(
                          title: OlukoLocalizations.get(context, 'recommended'),
                          height: carouselSectionHeight + 10,
                          children:
                              recommendationState.recommendationsByUsers.entries.map((MapEntry<String, List<UserResponse>> courseEntry) {
                            var courseList = _courses.where((element) => element.id == courseEntry.key).toList();
                            if (courseList.isNotEmpty) {
                              final course = courseList[0];

                              final List<String> userRecommendationAvatars =
                                  courseEntry.value.map((user) => user.avatar ?? defaultAvatar).toList();

                              return Padding(
                                padding: OlukoNeumorphism.isNeumorphismDesign
                                    ? const EdgeInsets.symmetric(vertical: 10, horizontal: 5)
                                    : const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing], arguments: {
                                    'course': course,
                                    'fromCoach': false,
                                    'isCoachRecommendation': coachId != null ? courseEntry.value.first.id == coachId : false
                                  }),
                                  child: _getCourseCard(_generateImageCourse(course.image),
                                      width: ScreenUtils.width(context) / (padding + _cardsToShow()),
                                      userRecommendationsAvatarUrls: userRecommendationAvatars),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          }).toList(),
                        )
                      : SizedBox();
                }),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget _activeCoursesSection() {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        AuthSuccess authSuccess = authState;
        List<Course> enrolledCourses = [];
        return BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
            bloc: BlocProvider.of<CourseEnrollmentListStreamBloc>(context)..getStream(authSuccess.user.id ?? authSuccess.user.firebaseId),
            builder: (context, courseEnrollmentState) {
              if (courseEnrollmentState is CourseEnrollmentsByUserStreamSuccess && (courseEnrollmentState.courseEnrollments.isNotEmpty)) {
                return CarouselSection(
                  title: OlukoLocalizations.get(context, 'activeCourses'),
                  height: carouselSectionHeight + 10,
                  children: courseEnrollmentState.courseEnrollments.map((CourseEnrollment courseEnrollment) {
                    final activeCourseList = _courses.where((enrolledCourse) => enrolledCourse.id == courseEnrollment.course.id).toList();
                    Course course;
                    int courseIndex = courseEnrollmentState.courseEnrollments.indexOf(courseEnrollment);
                    if (activeCourseList.isNotEmpty) {
                      course = activeCourseList[0];
                      enrolledCourses.add(course);
                      return Padding(
                        padding: OlukoNeumorphism.isNeumorphismDesign
                            ? const EdgeInsets.only(right: 12, bottom: 8, top: 8)
                            : const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.enrolledCourse], arguments: {
                            'course': course,
                            'fromCoach': false,
                            'isCoachRecommendation': false,
                            'courseEnrollment': courseEnrollment,
                            'courseIndex': courseIndex
                          }),
                          child: _getCourseCard(
                            _generateImageCourse(course.image),
                            progress: courseEnrollment.completion,
                            width: ScreenUtils.width(context) / (padding + _cardsToShow()),
                          ),
                        ),
                      );
                    } else {
                      return nil;
                    }
                  }).toList(),
                  optionLabel: OlukoLocalizations.get(context, 'viewAll'),
                  onOptionTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.viewAll],
                      arguments: {'courses': enrolledCourses, 'title': OlukoLocalizations.get(context, 'activeCourses')}),
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

  Widget _myListSection() {
    return Container(
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        return authState is AuthSuccess
            ? BlocBuilder<FavoriteBloc, FavoriteState>(
                bloc: BlocProvider.of<FavoriteBloc>(context)..getByUser(authState.user.id),
                builder: (context, favoriteState) {
                  return favoriteState is FavoriteSuccess && favoriteState.favorites.length > 0
                      ? CarouselSection(
                          title: OlukoLocalizations.get(context, 'myList'),
                          height: carouselSectionHeight,
                          children: favoriteState.favorites.map((Favorite favorite) {
                            Course favoriteCourse = _courses.where((course) => course.id == favorite.course.id).toList()[0];
                            return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                                        arguments: {'course': favoriteCourse, 'fromCoach': false, 'isCoachRecommendation': false});
                                  },
                                  child: _getCourseCard(
                                    _generateImageCourse(favoriteCourse.image),
                                    width: ScreenUtils.width(context) / (padding + _cardsToShow()),
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
      return Image(
        image: CachedNetworkImageProvider(imageUrl),
        fit: BoxFit.cover,
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
            ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 120),
      );
    }
    return Image.asset("assets/courses/course_sample_7.png");
    //TODO: fill space with default image or message
  }
}
