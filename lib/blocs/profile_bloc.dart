import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/profile_repository.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

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

  void updateUserProfileAvatar({DeviceContentFrom uploadedFrom}) async {
    if (!(state is ProfileUploadSuccess)) {
      emit(Loading());
    }
    PickedFile _image;
    try {
      final imagePicker = ImagePicker();
      if (uploadedFrom == DeviceContentFrom.gallery) {
        _image = await imagePicker.getImage(source: ImageSource.gallery);
      }
      if (uploadedFrom == DeviceContentFrom.camera) {
        _image = await imagePicker.getImage(source: ImageSource.gallery);
      }

      if (_image == null) return;

      UserResponse userUpdated =
          await _profileRepository.updateProfileAvatar(_image);
      emit(ProfileUploadSuccess(userUpdated: userUpdated));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void resetUploadStatus() {
    try {
      emit(NoUploads());
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
