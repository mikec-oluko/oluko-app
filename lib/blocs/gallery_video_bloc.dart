import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/services/assessment_service.dart';
import 'package:oluko_app/utils/permissions_utils.dart';

abstract class GalleryVideoState {}

class Loading extends GalleryVideoState {}

class Success extends GalleryVideoState {
  Uint8List firstVideo;
  XFile pickedFile;
  Success({this.pickedFile, this.firstVideo});
}

class PermissionsRequired extends GalleryVideoState {}

class Failure extends GalleryVideoState {
  final dynamic exception;

  Failure({this.exception});
}

class GalleryVideoBloc extends Cubit<GalleryVideoState> {
  GalleryVideoBloc() : super(Loading());
  Success currentState;
  void getVideoFromGallery() async {
    try {
      if (!await PermissionsUtils.permissionsEnabled(DeviceContentFrom.gallery, checkMicrophone: false)) {
        emit(PermissionsRequired());
        return;
      }
      final imagePicker = ImagePicker();
      XFile video = await imagePicker.pickVideo(source: ImageSource.gallery);
      currentState.pickedFile = video;
      emit(currentState);
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
      Uint8List pickedVideo = await AssesmentService.getFirstVideoGallery();
      currentState.firstVideo = pickedVideo;
      emit(currentState);
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
