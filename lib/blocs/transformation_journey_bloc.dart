import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvt_fitness/models/enums/file_type_enum.dart';
import 'package:mvt_fitness/models/transformation_journey_uploads.dart';
import 'package:mvt_fitness/repositories/transformation_journey_repository.dart';

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
    // if (!(state is TransformationJourneySuccess)) {
    //   emit(TransformationJourneyLoading());
    // }
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
}
