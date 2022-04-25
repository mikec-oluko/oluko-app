import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/tag.dart';

class SelectedTags {
  List<Tag> tags;
  SelectedTags({
    this.tags,
  });
}

class RemainSelectedTagsBloc extends Cubit<SelectedTags> {
  RemainSelectedTagsBloc() : super(SelectedTags(tags: []));

  void set(List<Tag> tags) => emit(SelectedTags(tags: tags));
  void get() => emit(SelectedTags(tags: state.tags));
}
