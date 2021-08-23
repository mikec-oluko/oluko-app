import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/transformation_journey_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class TransformationJourneyState {}

class TransformationJourneyLoading extends TransformationJourneyState {}

class TransformationJourneyDefault extends TransformationJourneyState {}

class TransformationJourneySuccess extends TransformationJourneyState {
  final List<TransformationJourneyUpload> contentFromUser;
  TransformationJourneySuccess({this.contentFromUser});
}

class TransformationJourneyUploadSuccess extends TransformationJourneyState {
  final List<TransformationJourneyUpload> contentFromUser;
  TransformationJourneyUploadSuccess({this.contentFromUser});
}

class TransformationJourneyFailure extends TransformationJourneyState {
  final Exception exception;

  TransformationJourneyFailure({this.exception});
}

class TransformationJourneyBloc extends Cubit<TransformationJourneyState> {
  TransformationJourneyBloc() : super(TransformationJourneyLoading());

  void getContentByUserId(String userId) async {
    try {
      List<TransformationJourneyUpload> contentUploaded =
          await TransformationJourneyRepository()
              .getUploadedContentByUserId(userId);
      emit(TransformationJourneySuccess(contentFromUser: contentUploaded));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(TransformationJourneyFailure(exception: e));
    }
  }

  Future<void> createTransformationJourneyUpload(FileTypeEnum type,
      PickedFile file, String userId, int indexForContent) async {
    try {
      TransformationJourneyUpload transformationJourneyUpload =
          await TransformationJourneyRepository
              .createTransformationJourneyUpload(
                  type, file, userId, indexForContent);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(TransformationJourneyFailure(exception: e));
    }
  }

  void emitTransformationJourneyFailure() {
    try {
      emit(TransformationJourneyFailure(
          exception: new Exception("Upload Aborted")));
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(TransformationJourneyFailure(exception: e));
    }
  }

  void emitTransformationJourneyDefault() {
    try {
      emit(TransformationJourneyDefault());
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(TransformationJourneyFailure(exception: e));
    }
  }
}
