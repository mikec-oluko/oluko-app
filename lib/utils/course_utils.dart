import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/submodels/course_category_item.dart';
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
    List<Course> coursesInCategorySorted = [];
    courseCategory.courses.forEach((courseFromCategory) {
      if (_courseFromCategoryCourseList(courses, courseFromCategory).isNotEmpty) {
        coursesInCategorySorted.add(_courseFromCategoryCourseList(courses, courseFromCategory).first);
      }
    });
    return coursesInCategorySorted;
  }

  static Iterable<Course> _courseFromCategoryCourseList(List<Course> courses, CourseCategoryItem courseFromCategory) =>
      courses.where((actualCourse) => actualCourse.id == courseFromCategory.id);

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

  static Widget noCourseText(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 30, top: 20),
        child: Text(
          OlukoLocalizations.get(context, 'noCourseFound'),
          style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
        ));
  }

  static String toCourseDuration(int weeks, int classes, BuildContext context) {
    return "$weeks ${OlukoLocalizations.get(context, 'weeks')}, $classes ${OlukoLocalizations.get(context, 'classes')}";
  }

  static Course getCourseById(String courseId, List<Course> courses) {
    if(courses.isEmpty){
      return null;
    }
    return courses?.where((course) => course.id == courseId)?.first;
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
