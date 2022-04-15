import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/repositories/profile_repository.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:oluko_app/models/utils/oluko_bloc_exception.dart';
import 'package:path/path.dart' as p;

abstract class ProfileCoverImageState {}

class ProfileCoverImageOpen extends ProfileCoverImageState {}

class ProfileCoverImageLoading extends ProfileCoverImageState {}

class ProfileCoverImageDefault extends ProfileCoverImageState {}

class ProfileCoverSuccess extends ProfileCoverImageState {}

class ProfileCoverImageFailure extends OlukoException with ProfileCoverImageState {
  ProfileCoverImageFailure({ExceptionTypeEnum exceptionType, ExceptionTypeSourceEnum exceptionSource, dynamic exception})
      : super(exceptionType: exceptionType, exception: exception, exceptionSource: exceptionSource);
}

class ProfileCoverRequirePermissions extends ProfileCoverImageState {}

class ProfileCoverImageBloc extends Cubit<ProfileCoverImageState> {
  ProfileCoverImageBloc() : super(ProfileCoverImageDefault());
  final ProfileRepository _profileRepository = ProfileRepository();

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
        emit(ProfileCoverImageFailure(
            exception: Exception(),
            exceptionType: ExceptionTypeEnum.loadFileFailed,
            exceptionSource: ExceptionTypeSourceEnum.noFileSelected));
        return;
      } else if (!(p.extension(_image.path) == ImageUtils.jpegFormat ||
          p.extension(_image.path) == ImageUtils.jpgFormat ||
          p.extension(_image.path) == ImageUtils.pngFormat)) {
        emit(ProfileCoverImageFailure(
            exception: Exception(), exceptionType: ExceptionTypeEnum.uploadFailed, exceptionSource: ExceptionTypeSourceEnum.invalidFormat));
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
