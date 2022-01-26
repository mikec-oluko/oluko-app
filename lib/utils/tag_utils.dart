import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/models/tag_category.dart';
import 'package:oluko_app/models/submodels/tag_category_item.dart';

class TagUtils {
  static List<Tag> filterByCategories(List<Tag> courses, TagCategory courseCategory) {
    List<Tag> toShow = [];
    courses.forEach((Tag tag) {
      List<String> courseIds = courseCategory.tags.map((TagCategoryItem courseCategoryItem) => courseCategoryItem.id).toList();

      if (courseIds.indexOf(tag.id) != -1) {
        toShow.add(tag);
      }
    });
    return toShow;
  }

  /*
  Returns Map with a list of Tags for each Category
  */
  static Map<TagCategory, List<Tag>> mapTagsByCategories(List<Tag> tags, List<TagCategory> courseCategories) {
    Map<TagCategory, List<Tag>> mappedCourses = {};
    courseCategories.forEach((courseCategory) {
      final List<Tag> tagList = filterByCategories(tags, courseCategory);
      mappedCourses[courseCategory] = tagList;
    });
    return mappedCourses;
  }

  static List<Tag> sortByIndex(List<Tag> items, TagCategory itemCategory) {
    items.sort((Tag tagA, Tag tagB) {
      int itemCategoryAIndex = itemCategory.tags.indexWhere((TagCategoryItem element) => element.id == tagA.id);
      int itemCategoryBIndex = itemCategory.tags.indexWhere((TagCategoryItem element) => element.id == tagB.id);
      return itemCategoryAIndex.compareTo(itemCategoryBIndex);
    });
    return items;
  }
}
