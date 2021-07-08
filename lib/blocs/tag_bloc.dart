import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvt_fitness/models/tag.dart';
import 'package:mvt_fitness/models/tag_category.dart';
import 'package:mvt_fitness/repositories/tag_category_repository.dart';
import 'package:mvt_fitness/repositories/tag_repository.dart';
import 'package:mvt_fitness/utils/tag_utils.dart';

abstract class TagState {}

class TagLoading extends TagState {}

class TagSuccess extends TagState {
  final List<Tag> values;
  final Map<TagCategory, List<Tag>> tagsByCategories;
  TagSuccess({this.values, this.tagsByCategories});
}

class TagFailure extends TagState {
  final Exception exception;

  TagFailure({this.exception});
}

class TagBloc extends Cubit<TagState> {
  TagBloc() : super(TagLoading());

  void get() async {
    if (!(state is TagSuccess)) {
      emit(TagLoading());
    }
    try {
      List<Tag> tags = await TagRepository().getAll();
      emit(TagSuccess(values: tags));
    } catch (e) {
      emit(TagFailure(exception: e));
    }
  }

  void getByCategories() async {
    if (!(state is TagSuccess)) {
      emit(TagLoading());
    }
    try {
      List<Tag> tags = await TagRepository().getAll();
      List<TagCategory> tagCategories = await TagCategoryRepository().getAll();
      Map<TagCategory, List<Tag>> mappedTags =
          TagUtils.mapTagsByCategories(tags, tagCategories);
      emit(TagSuccess(values: tags, tagsByCategories: mappedTags));
    } catch (e) {
      emit(TagFailure(exception: e));
    }
  }
}
