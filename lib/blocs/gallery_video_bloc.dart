import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

abstract class GalleryVideoState {}

class Loading extends GalleryVideoState {}

class Success extends GalleryVideoState {
  PickedFile pickedFile;
  Success({this.pickedFile});
}

class Failure extends GalleryVideoState {
  final dynamic exception;

  Failure({this.exception});
}

class GalleryVideoBloc extends Cubit<GalleryVideoState> {
  GalleryVideoBloc() : super(Loading());

  void getVideoFromGallery() async {
    try {
      final imagePicker = ImagePicker();
      PickedFile video =
          await imagePicker.getVideo(source: ImageSource.gallery);
      emit(Success(pickedFile: video));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
