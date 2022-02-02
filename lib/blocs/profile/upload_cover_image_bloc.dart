import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/repositories/profile_repository.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ProfileCoverImageState {}

class ProfileCoverImageOpen extends ProfileCoverImageState {}

class ProfileCoverImageLoading extends ProfileCoverImageState {
  // bool lockPanel = false;
  // ProfileCoverImageLoading({this.lockPanel = false});
}

class ProfileCoverImageDefault extends ProfileCoverImageState {}

class ProfileCoverSuccess extends ProfileCoverImageState {
  // bool lockPanel = false;
  // ProfileCoverSuccess({this.lockPanel = false});
}

class ProfileCoverImageFailure extends ProfileCoverImageState {
  dynamic exception;
  ProfileCoverImageFailure({this.exception});
}

class ProfileCoverRequirePermissions extends ProfileCoverImageState {}

class ProfileCoverImageBloc extends Cubit<ProfileCoverImageState> {
  ProfileCoverImageBloc() : super(ProfileCoverImageDefault());
  ProfileRepository _profileRepository = ProfileRepository();

  void uploadProfileCoverImage({DeviceContentFrom uploadedFrom}) async {
    XFile _image;

    try {

      if (!await PermissionsUtils.permissionsEnabled(uploadedFrom, checkMicrophone: false)) {
        emit(ProfileCoverRequirePermissions());
        return;
      }
      
      final ImagePicker imagePicker = ImagePicker();
      if (uploadedFrom == DeviceContentFrom.gallery) {
        _image = await imagePicker.pickImage(source: ImageSource.gallery);
      } else if (uploadedFrom == DeviceContentFrom.camera) {
        _image = await imagePicker.pickImage(source: ImageSource.camera);
      }
      if (_image == null && _image is! XFile) {
        emit(ProfileCoverImageFailure(exception: Exception()));
        return;
      }
      emit(ProfileCoverImageLoading());
      await _profileRepository.uploadProfileCoverImage(_image);
      emit(ProfileCoverSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      emit(ProfileCoverImageFailure(exception: exception));
      // rethrow;
      return;
    }
  }

  void emitDefaultState() {
    emit(ProfileCoverImageDefault());
  }

  void openPanel() {
    emit(ProfileCoverImageOpen());
  }
}
