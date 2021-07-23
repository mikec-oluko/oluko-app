import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/transformation_journey_repository.dart';

abstract class TransformationJourneyState {}

class TransformationJourneyLoading extends TransformationJourneyState {}

class TransformationJourneySuccess extends TransformationJourneyState {
  final List<TransformationJourneyUpload> contentFromUser;
  TransformationJourneySuccess({this.contentFromUser});
}

class TransformationJourneyFailure extends TransformationJourneyState {
  final Exception exception;

  TransformationJourneyFailure({this.exception});
}

class TransformationJourneyBloc extends Cubit<TransformationJourneyState> {
  TransformationJourneyBloc() : super(TransformationJourneyLoading());

  void getContentByUserName(String userName) async {
    try {
      List<TransformationJourneyUpload> contentUploaded =
          await TransformationJourneyRepository()
              .getUploadedContentByUserName(userName);
      emit(TransformationJourneySuccess(contentFromUser: contentUploaded));
    } catch (e) {
      emit(TransformationJourneyFailure(exception: e));
    }
  }

  Future<void> createTransformationJourneyUpload(
      FileTypeEnum type, PickedFile file, String username) async {
    try {
      TransformationJourneyUpload transformationJourneyUpload =
          await TransformationJourneyRepository
              .createTransformationJourneyUpload(type, file, username);
      //emit(CreateSuccess(taskSubmissionId: newTaskSubmission.id));
    } catch (e) {
      //emit(Failure(exception: e));
    }
  }

  void uploadTransformationJourneyContent() async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.getImage(source: ImageSource.gallery);
      if (image == null) return;

      UserResponse user = await AuthRepository().retrieveLoginData();

      TransformationJourneyUpload upload = await TransformationJourneyRepository
          .createTransformationJourneyUpload(
              FileTypeEnum.image, image, user.username);

      List<TransformationJourneyUpload> contentUploaded =
          await TransformationJourneyRepository()
              .getUploadedContentByUserName(user.username);

      emit(TransformationJourneySuccess(contentFromUser: contentUploaded));
    } catch (e) {
      emit(TransformationJourneyFailure(exception: e));
    }
  }
}
