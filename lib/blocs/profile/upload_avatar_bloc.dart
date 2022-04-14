import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/utils/oluko_bloc_exception.dart';
import 'package:oluko_app/repositories/profile_repository.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path/path.dart' as p;

abstract class ProfileAvatarState {}

class ProfileAvatarLoading extends ProfileAvatarState {}

class ProfileAvatarDefault extends ProfileAvatarState {}

class ProfileAvatarOpenPanel extends ProfileAvatarState {}

class ProfileAvatarSuccess extends ProfileAvatarState {}

class ProfileAvatarFailure extends OlukoException with ProfileAvatarState {
  ProfileAvatarFailure({ExceptionTypeEnum exceptionType, ExceptionTypeSourceEnum exceptionSource, dynamic exception})
      : super(exceptionType: exceptionType, exception: exception, exceptionSource: exceptionSource);
}

class ProfileAvatarRequirePermissions extends ProfileAvatarState {}

class ProfileAvatarBloc extends Cubit<ProfileAvatarState> {
  ProfileAvatarBloc() : super(ProfileAvatarDefault());
  final ProfileRepository _profileRepository = ProfileRepository();

  void uploadProfileAvatarImage({DeviceContentFrom uploadedFrom, UploadFrom contentFor}) async {
    XFile _image;
    try {
      if (!await PermissionsUtils.permissionsEnabled(uploadedFrom, checkMicrophone: false)) {
        emit(ProfileAvatarRequirePermissions());
        return;
      }

      final ImagePicker imagePicker = ImagePicker();

      if (uploadedFrom == DeviceContentFrom.gallery) {
        _image = await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 360, maxHeight: 360, imageQuality: 75);
      } else if (uploadedFrom == DeviceContentFrom.camera) {
        _image = await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 360, maxHeight: 360, imageQuality: 75);
      }

      if (_image == null && _image is! XFile) {
        emit(ProfileAvatarFailure(
            exception: Exception(),
            exceptionType: ExceptionTypeEnum.loadFileFailed,
            exceptionSource: ExceptionTypeSourceEnum.noFileSelected));
        return;
      } else if (p.extension(_image.path) != ImageUtils.jpegFormat && p.extension(_image.path) != ImageUtils.jpgFormat && p.extension(_image.path) != ImageUtils.pngFormat) {
        emit(ProfileAvatarFailure(
            exception: Exception(), exceptionType: ExceptionTypeEnum.uploadFailed, exceptionSource: ExceptionTypeSourceEnum.invalidFormat));
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
      emit(ProfileAvatarFailure(exception: exception, exceptionType: ExceptionTypeEnum.appFailed));
      return;
    }
  }

  void emitDefaultState() {
    emit(ProfileAvatarDefault());
  }

  void openPanel() {
    emit(ProfileAvatarOpenPanel());
  }
}
