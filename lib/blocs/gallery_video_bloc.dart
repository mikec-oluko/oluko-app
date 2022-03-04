import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/services/content_from_gallery_service.dart';
import 'package:oluko_app/utils/permissions_utils.dart';

abstract class GalleryVideoState {}

class Loading extends GalleryVideoState {}

class NoContent extends GalleryVideoState {}

class Success extends GalleryVideoState {
  Uint8List firstVideo;
  Uint8List firstImage;
  XFile pickedFile;
  Success({this.pickedFile, this.firstVideo,this.firstImage});
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
      XFile video = await imagePicker.pickVideo(source: ImageSource.gallery);
      emit(Success(pickedFile: video));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getFirstVideoFromGalley() async {
    try {
      if (!await PermissionsUtils.permissionsEnabled(DeviceContentFrom.gallery, checkMicrophone: false)) {
        emit(PermissionsRequired());
        return;
      }
      Uint8List pickedVideo = await ContentFromGalleyService.getFirstVideoGallery();
       if (pickedVideo != null) {
        emit(Success(firstVideo:pickedVideo ));
      } else {
        emit(NoContent());
      }
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getFirstImageFromGalley() async {
    try {
      if (!await PermissionsUtils.permissionsEnabled(DeviceContentFrom.gallery, checkMicrophone: false)) {
        emit(PermissionsRequired());
        return;
      }
      Uint8List pickedImage = await ContentFromGalleyService.getFirstImageGallery();
      if (pickedImage != null) {
        emit(Success(firstImage: pickedImage));
      } else {
        emit(NoContent());
      }
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
