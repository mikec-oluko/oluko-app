import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/permissions.dart';
import 'package:oluko_app/repositories/profile_repository.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path/path.dart' as p;

abstract class ProfileAvatarState {}

class ProfileAvatarLoading extends ProfileAvatarState {
  // bool lockPanel = false;
  // ProfileAvatarLoading({this.lockPanel = false});
}

class ProfileAvatarDefault extends ProfileAvatarState {}

class ProfileAvatarOpenPanel extends ProfileAvatarState {}

class ProfileAvatarSuccess extends ProfileAvatarState {
  // bool lockPanel = false;
  // ProfileAvatarSuccess({this.lockPanel = false});
}

class ProfileAvatarFailure extends ProfileAvatarState {
  dynamic exception;
  ProfileAvatarFailure({this.exception});
}

class ProfileAvatarRequirePermissions extends ProfileAvatarState {}

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

      if (_image == null && _image is! PickedFile) {
        emit(ProfileAvatarFailure(exception: Exception()));
        return;
      } else if (p.extension(_image.path) != ImageUtils.jpegFormat && p.extension(_image.path) != ImageUtils.jpgFormat) {
        emit(ProfileAvatarFailure(exception: Exception()));
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

      if (!await requiredAvatarPermissionsEnabled(uploadedFrom)) return;

      emit(ProfileAvatarFailure(exception: exception));
      // rethrow;
      return;
    }
  }

  Future<bool> requiredAvatarPermissionsEnabled(DeviceContentFrom uploadedFrom) async {
    if (!await Permissions.requiredPermissionsEnabled(uploadedFrom)) {
      emit(ProfileAvatarRequirePermissions());
      return false;
    }
    return true;
  }

  void emitDefaultState() {
    emit(ProfileAvatarDefault());
  }

  void openPanel() {
    emit(ProfileAvatarOpenPanel());
  }
}
