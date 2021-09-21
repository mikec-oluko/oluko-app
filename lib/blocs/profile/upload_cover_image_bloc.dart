import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/permissions.dart';
import 'package:oluko_app/repositories/profile_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ProfileCoverImageState {}

class ProfileCoverImageOpen extends ProfileCoverImageState {}

class ProfileCoverImageLoading extends ProfileCoverImageState {}

class ProfileCoverImageDefault extends ProfileCoverImageState {}

class ProfileCoverSuccess extends ProfileCoverImageState {
  ProfileCoverSuccess();
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
    PickedFile _image;

    try {
      final imagePicker = ImagePicker();
      if (uploadedFrom == DeviceContentFrom.gallery) {
        _image = await imagePicker.getImage(source: ImageSource.gallery);
      } else if (uploadedFrom == DeviceContentFrom.camera) {
        _image = await imagePicker.getImage(source: ImageSource.camera);
      }
      if (_image == null) {
        emit(ProfileCoverImageFailure(exception: new Exception()));
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

      if (!await requiredCoverPermissionsEnabled(uploadedFrom)) return;

      emit(ProfileCoverImageFailure(exception: exception));
      rethrow;
    }
  }

  Future<bool> requiredCoverPermissionsEnabled(DeviceContentFrom uploadedFrom) async {
    if (!await Permissions.requiredPermissionsEnabled(uploadedFrom)) {
      emit(ProfileCoverRequirePermissions());
      return false;
    }
    return true;
  }

  void emitDefaultState() {
    emit(ProfileCoverImageDefault());
  }

  void openPanel() {
    emit(ProfileCoverImageOpen());
  }
}
