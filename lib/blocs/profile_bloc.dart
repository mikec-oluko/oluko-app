import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/profile_repository.dart';

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

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc() : super(Loading());

  ProfileRepository _profileRepository = ProfileRepository();

  void updateUserProfileAvatar() async {
    if (!(state is ProfileUploadSuccess)) {
      emit(Loading());
    }
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.getImage(source: ImageSource.gallery);
      if (image == null) return;
      UserResponse userUpdated =
          await _profileRepository.updateProfileAvatar(image);
      emit(ProfileUploadSuccess(userUpdated: userUpdated));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
