import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/permissions_utils.dart';

abstract class GalleryVideoState {}

class Loading extends GalleryVideoState {}

class Success extends GalleryVideoState {
  PickedFile pickedFile;
  Success({this.pickedFile});
}

class PermissionsRequired extends GalleryVideoState {}

class Failure extends GalleryVideoState {
  final dynamic exception;

  Failure({this.exception});
}

class GalleryVideoBloc extends Cubit<GalleryVideoState> {
  GalleryVideoBloc() : super(Loading());

  void getVideoFromGallery() async {
    try {
      if (!await PermissionsUtils.permissionsEnabled(DeviceContentFrom.gallery, checkMicrophone: false)) {
        emit(PermissionsRequired());
        return;
      }

      final imagePicker = ImagePicker();
      PickedFile video = await imagePicker.getVideo(source: ImageSource.gallery);
      emit(Success(pickedFile: video));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
