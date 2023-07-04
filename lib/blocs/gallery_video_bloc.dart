import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/video_format_validator.dart';
import 'package:oluko_app/services/content_from_gallery_service.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:path/path.dart' as p;

abstract class GalleryVideoState {}

class Loading extends GalleryVideoState {}

class NoContent extends GalleryVideoState {}

class Success extends GalleryVideoState {
  Uint8List firstVideo;
  Uint8List firstImage;
  XFile pickedFile;
  Success({this.pickedFile, this.firstVideo, this.firstImage});
}

class PermissionsRequired extends GalleryVideoState {
  String permissionRequired;
  PermissionsRequired({this.permissionRequired});
}

class UploadFailure extends GalleryVideoState {
  final dynamic exception;
  final bool badFormat;

  UploadFailure({this.exception, this.badFormat = false});
}

class GalleryVideoBloc extends Cubit<GalleryVideoState> {
  GalleryVideoBloc() : super(Loading());
  void getVideoFromGallery() async {
    try {
      if (!await PermissionsUtils.permissionsEnabled(DeviceContentFrom.gallery, checkMicrophone: false)) {
        emit(PermissionsRequired(permissionRequired: DeviceContentFrom.gallery.name));
        return;
      }
      final imagePicker = ImagePicker();
      XFile video = await imagePicker.pickVideo(source: ImageSource.gallery);
      final extension = p.extension(video.path);
      if (!VideoFormatValidator.formatValidator(extension)) {
        emit(UploadFailure(badFormat: true));
        return;
      }
      emit(Success(pickedFile: video));
    } catch (e) {
      emit(UploadFailure(
        exception: e,
      ));
    }
  }

  void getFirstVideoFromGalley() async {
    try {
      if (!await PermissionsUtils.permissionsEnabled(DeviceContentFrom.gallery, checkMicrophone: false)) {
        emit(NoContent());
        return;
      }
      Uint8List pickedVideo = await ContentFromGalleyService.getFirstVideoGallery();
      if (pickedVideo != null) {
        emit(Success(firstVideo: pickedVideo));
      } else {
        emit(NoContent());
      }
    } catch (e) {
      emit(UploadFailure(exception: e));
    }
  }

  void getFirstImageFromGalley() async {
    try {
      if (!await PermissionsUtils.permissionsEnabled(DeviceContentFrom.gallery, checkMicrophone: false)) {
        emit(NoContent());
        return;
      }
      Uint8List pickedImage = await ContentFromGalleyService.getFirstImageGallery();
      if (pickedImage != null) {
        emit(Success(firstImage: pickedImage));
      } else {
        emit(NoContent());
      }
    } catch (e) {
      emit(UploadFailure(exception: e));
    }
  }
}
