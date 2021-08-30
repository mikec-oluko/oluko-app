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
import 'package:oluko_app/utils/screen_utils.dart';

class CourseUtils {
  static List<Course> filterByCategories(
      List<Course> courses, CourseCategory courseCategory) {
    List<Course> tasksToShow = [];
    courses.forEach((Course course) {
      List<String> courseIds = courseCategory.courses
          .map((CourseCategoryItem courseCategoryItem) => courseCategoryItem.id)
          .toList();

      if (courseIds.indexOf(course.id) != -1) {
        tasksToShow.add(course);
      }
    });
    return tasksToShow;
  }

  /*
  Returns Map with a list of Courses for each Category
  */
  static Map<CourseCategory, List<Course>> mapCoursesByCategories(
      List<Course> courses, List<CourseCategory> courseCategories) {
    Map<CourseCategory, List<Course>> mappedCourses = {};
    courseCategories.forEach((courseCategory) {
      final List<Course> courseList =
          filterByCategories(courses, courseCategory);
      mappedCourses[courseCategory] = courseList;
    });
    return mappedCourses;
  }

  static List<Course> sortByCategoriesIndex(
      List<Course> courses, CourseCategory courseCategory) {
    courses.sort((Course courseCategoryA, Course courseCategoryB) {
      int courseCategoryAIndex = courseCategory.courses.indexWhere(
          (CourseCategoryItem element) => element.id == courseCategoryA.id);
      int courseCategoryBIndex = courseCategory.courses.indexWhere(
          (CourseCategoryItem element) => element.id == courseCategoryB.id);
      return courseCategoryAIndex.compareTo(courseCategoryBIndex);
    });
    return courses;
  }

  static List<Course> searchMethod(String query, List<Course> collection,
      {List<Tag> selectedTags = const []}) {
    List<Course> resultsWithoutFilters = collection
        .where(
            (course) => course.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    List<Course> filteredResults = resultsWithoutFilters.where((Course course) {
      final List<String> courseTagIds =
          course.tags != null ? course.tags.map((e) => e.id).toList() : [];
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

  static List<Course> suggestionMethod(String query, List<Course> collection) {
    return collection
        .where((course) =>
            course.name.toLowerCase().indexOf(query.toLowerCase()) == 0)
        .toList();
  }

  static Widget searchSuggestions(SearchResults<Course> search,
      GlobalKey<SearchState<dynamic>> searchBarKey) {
    return SearchSuggestions<Course>(
        textInput: search.query,
        itemList: search.suggestedItems,
        onPressed: (dynamic item) =>
            searchBarKey.currentState.updateSearchResults(item.name),
        keyNameList: search.suggestedItems.map((e) => e.name).toList());
  }

  static SearchResultsGrid<Course> searchResults(
      BuildContext context,
      SearchResults<Course> search,
      double cardsAspectRatio,
      num searchResultsToShowPortrait,
      num searchResultsToShowLandscape) {
    return SearchResultsGrid<Course>(
        childAspectRatio: cardsAspectRatio,
        crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? searchResultsToShowPortrait
                : searchResultsToShowLandscape,
        textInput: search.query,
        itemList: search.searchResults);
  }

  static Future<bool> onClearFilters(context) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: Colors.grey.shade900,
            content: Container(
              height: 150,
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

  static Widget filterSelector(TagSuccess state,
      {Function(List<Base>) onSubmit,
      Function() onClosed,
      List<Tag> selectedTags = const []}) {
    return Padding(
        padding: EdgeInsets.only(top: 15.0, left: 8, right: 8),
        child: FilterSelector<Tag>(
            itemList: Map.fromIterable(state.tagsByCategories.entries,
                key: (entry) => entry.key.name,
                value: (entry) => Map.fromIterable(entry.value,
                    key: (tag) => tag, value: (tag) => tag.name)),
            selectedTags: selectedTags,
            onSubmit: onSubmit,
            onClosed: onClosed));
  }
}
