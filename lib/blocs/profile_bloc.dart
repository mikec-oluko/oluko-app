import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/profile_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ProfileState {}

class Loading extends ProfileState {}

class ProfileUploadSuccess extends ProfileState {
  final UserResponse userUpdated;
  ProfileUploadSuccess({this.userUpdated});
}

class Failure extends ProfileState {
  final Exception exception;

  Failure({this.exception});
}

class NoUploads extends ProfileState {}

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc() : super(Loading());

  ProfileRepository _profileRepository = ProfileRepository();

  void uploadImageForProfile(
      {DeviceContentFrom uploadedFrom, UploadFrom contentFor}) async {
    PickedFile _image;

    if (!(state is ProfileUploadSuccess)) {
      emit(Loading());
    }
    try {
      final imagePicker = ImagePicker();
      if (uploadedFrom == DeviceContentFrom.gallery) {
        _image = await imagePicker.getImage(source: ImageSource.gallery);
      }
      if (uploadedFrom == DeviceContentFrom.camera) {
        _image = await imagePicker.getImage(source: ImageSource.camera);
      }

      if (_image == null) {
        emit(Failure(exception: new Exception("Profile upload aborted")));
        return;
      }

      if (contentFor == UploadFrom.profileCoverImage) {
        UserResponse userUpdatedCoverImage =
            await _profileRepository.uploadProfileCoverImage(_image);
        emit(ProfileUploadSuccess(userUpdated: userUpdatedCoverImage));
      }
      if (contentFor == UploadFrom.profileImage) {
        UserResponse userUpdated =
            await _profileRepository.updateProfileAvatar(_image);
        emit(ProfileUploadSuccess(userUpdated: userUpdated));
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }

  void updateSettingsPreferences(UserResponse userToUpdate, int privacyIndex,
      bool notificationValue) async {
    try {
      await _profileRepository.updateUserPreferences(
          userToUpdate, privacyIndex, notificationValue);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }
}
