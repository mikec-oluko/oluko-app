import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/repositories/profile_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ProfileAvatarState {}

class ProfileAvatarLoading extends ProfileAvatarState {}

class ProfileAvatarDefault extends ProfileAvatarState {}

class ProfileAvatarOpenPanel extends ProfileAvatarState {}

class ProfileAvatarSuccess extends ProfileAvatarState {
  ProfileAvatarSuccess();
}

class ProfileAvatarFailure extends ProfileAvatarState {
  dynamic exception;
  ProfileAvatarFailure({this.exception});
}

class ProfileAvatarBloc extends Cubit<ProfileAvatarState> {
  ProfileAvatarBloc() : super(ProfileAvatarDefault());
  ProfileRepository _profileRepository = ProfileRepository();

  void uploadProfileAvatarImage({DeviceContentFrom uploadedFrom, UploadFrom contentFor}) async {
    PickedFile _image;

    try {
      final imagePicker = ImagePicker();
      if (uploadedFrom == DeviceContentFrom.gallery) {
        _image = await imagePicker.getImage(source: ImageSource.gallery);
      } else if (uploadedFrom == DeviceContentFrom.camera) {
        _image = await imagePicker.getImage(source: ImageSource.camera);
      }

      if (_image == null) {
        emit(ProfileAvatarFailure(exception: new Exception()));
        return;
      }
      emit(ProfileAvatarLoading());
      await _profileRepository.updateProfileAvatar(_image);
      emit(ProfileAvatarSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(ProfileAvatarFailure(exception: exception));
      rethrow;
    }
  }

  void emitDefaultState() {
    emit(ProfileAvatarDefault());
  }

  void openPanel() {
    emit(ProfileAvatarOpenPanel());
  }
}
