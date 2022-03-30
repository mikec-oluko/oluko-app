import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SelectedTagState {}

class SelectedTagsLoading extends SelectedTagState {}

class SelectedTagsUpdated extends SelectedTagState {
  final int tagsQty;
  SelectedTagsUpdated({this.tagsQty});
}

class SelectedTagsBloc extends Cubit<SelectedTagState> {
  SelectedTagsBloc() : super(SelectedTagsLoading());

  void updateSelectedTags(int tagsQty) {
    emit(SelectedTagsUpdated(tagsQty: tagsQty));
  }
}
