import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/submodels/course_category_item.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/ui/components/filter_selector.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/search_results_grid.dart';
import 'package:oluko_app/ui/components/search_suggestions.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseUtils {
  static final int cardsToShowOnPortrait = 3;
  static final int cardsToShowOnLandscape = 4;
  static final double cardsAspectRatio = 0.69333;
  static final int carSecHeigthPlus = OlukoNeumorphism.isNeumorphismDesign ? 50 : 75;

  static double getCarouselSectionHeight(BuildContext context) {
    return ((ScreenUtils.width(context) / cardsToShow(context)) / cardsAspectRatio) + carSecHeigthPlus;
  }

  static int cardsToShow(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return cardsToShowOnPortrait;
    } else {
      return cardsToShowOnLandscape;
    }
  }

  static List<Course> filterByCategories(List<Course> courses, CourseCategory courseCategory) {
    List<Course> tasksToShow = [];
    courses.forEach((Course course) {
      List<String> courseIds = courseCategory.courses.map((CourseCategoryItem courseCategoryItem) => courseCategoryItem.id).toList();

      if (courseIds.indexOf(course.id) != -1) {
        tasksToShow.add(course);
      }
    });
    return tasksToShow;
  }

  /*
  Returns Map with a list of Courses for each Category
  */
  static Map<CourseCategory, List<Course>> mapCoursesByCategories(List<Course> courses, List<CourseCategory> courseCategories) {
    Map<CourseCategory, List<Course>> mappedCourses = {};
    courseCategories.forEach((courseCategory) {
      final List<Course> courseList = filterByCategories(courses, courseCategory);
      mappedCourses[courseCategory] = courseList;
    });
    return mappedCourses;
  }

  static List<Course> sortByCategoriesIndex(List<Course> courses, CourseCategory courseCategory) {
    courses.sort((Course courseCategoryA, Course courseCategoryB) {
      int courseCategoryAIndex = courseCategory.courses.indexWhere((CourseCategoryItem element) => element.id == courseCategoryA.id);
      int courseCategoryBIndex = courseCategory.courses.indexWhere((CourseCategoryItem element) => element.id == courseCategoryB.id);
      return courseCategoryAIndex.compareTo(courseCategoryBIndex);
    });
    return courses;
  }

  static List<Course> searchMethod(String query, List<Course> collection, List<Tag> selectedTags) {
    List<Course> resultsWithoutFilters = collection.where((course) => course.name.toLowerCase().contains(query.toLowerCase())).toList();
    List<Course> filteredResults = resultsWithoutFilters.where((Course course) {
      final List<String> courseTagIds = course.tags != null ? course.tags.map((e) => e.id).toList() : [];
      final List<String> selectedTagIds = selectedTags.map((e) => e.id).toList();
      //Return true if no filters are selected
      if (selectedTags.isEmpty) {
        return true;
      }
      //Check if this course match with the current tag filters.
      bool tagMatch = true;
      for (var i = 0; i < selectedTagIds.length && tagMatch; i++) {
        if (!courseTagIds.contains(selectedTagIds[i])) {
          tagMatch = false;
        }
      }
      return tagMatch;
    }).toList();
    return filteredResults;
  }

  static List<Course> suggestionMethod(String query, List<Course> collection) {
    return collection.where((course) => course.name.toLowerCase().indexOf(query.toLowerCase()) == 0).toList();
  }

  static Widget searchSuggestions(SearchResults<Course> search, GlobalKey<SearchState<dynamic>> searchBarKey, BuildContext context) {
    return search.suggestedItems.isEmpty
        ? noCourseText(context)
        : SearchSuggestions<Course>(
            textInput: search.query,
            itemList: search.suggestedItems,
            onPressed: (dynamic item) => {searchBarKey.currentState.updateSearchResults(item.name.toString())},
            keyNameList: search.suggestedItems.map((e) => e.name).toList());
  }

  static Widget searchResults(
      BuildContext context, SearchResults<Course> search, double cardsAspectRatio, int searchResultsToShowPortrait, int searchResultsToShowLandscape) {
    return search.searchResults.isEmpty
        ? noCourseText(context)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 25, bottom: 15),
                child: Text(
                  '${OlukoLocalizations.get(context, 'result')} ${search.searchResults.length} ${OlukoLocalizations.get(context, 'courses').toLowerCase()}',
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: SearchResultsGrid<Course>(
                    childAspectRatio: cardsAspectRatio,
                    crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? searchResultsToShowPortrait : searchResultsToShowLandscape,
                    textInput: search.query,
                    itemList: search.searchResults),
              ),
            ],
          );
  }

  static Widget noCourseText(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 30, top: 20),
        child: Text(
          OlukoLocalizations.get(context, 'noCourseFound'),
          style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
        ));
  }

  static Widget filterSelector(TagSuccess state,
      {Function(List<Base>) onSubmit, Function() onClosed, List<Tag> selectedTags = const [], Function showBottomTab}) {
    return Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 0, right: 0),
        child: FilterSelector<Tag>(
          itemList: Map.fromIterable(state.tagsByCategories.entries,
              key: (entry) => entry.key.name.toString(),
              value: (entry) => Map.fromIterable(entry.value as Iterable, key: (tag) => tag as Tag, value: (tag) => tag.name.toString())),
          selectedTags: selectedTags,
          onSubmit: onSubmit,
          onClosed: onClosed,
          showBottonTab: showBottomTab,
        ));
  }

  static String toCourseDuration(int weeks, int classes, BuildContext context) {
    return "$weeks ${OlukoLocalizations.get(context, 'weeks')}, $classes ${OlukoLocalizations.get(context, 'classes')}";
  }

  static Course getCourseById(String courseId, List<Course> courses) {
    return courses.where((course) => course.id == courseId).first;
  }

  static Widget generateImageCourse(String imageUrl, BuildContext context) {
    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: ScreenUtils.height(context) * 0.20,
        width: ScreenUtils.width(context) * 0.35,
        maxWidthDiskCache: (ScreenUtils.width(context) * 0.5).toInt(),
        maxHeightDiskCache: (ScreenUtils.height(context) * 0.5).toInt(),
        memCacheWidth: (ScreenUtils.width(context) * 0.5).toInt(),
        memCacheHeight: (ScreenUtils.height(context) * 0.5).toInt(),
        fit: BoxFit.fill,
      );
    }
    return Image.asset("assets/courses/course_sample_7.png");
    //TODO: fill space with default image or message
  }
}
