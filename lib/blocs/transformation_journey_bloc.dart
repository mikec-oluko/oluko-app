import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/repositories/transformation_journey_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class TransformationJourneyState {}

class TransformationJourneyLoading extends TransformationJourneyState {}

class TransformationJourneyDeleteSuccess extends TransformationJourneyState {
  bool elementDeleted;
  TransformationJourneyDeleteSuccess({this.elementDeleted});
}

class TransformationJourneyDefault extends TransformationJourneyState {}

class TransformationJourneyDefaultValue extends TransformationJourneyState {
  final List<TransformationJourneyUpload> contentFromUser;
  TransformationJourneyDefaultValue({this.contentFromUser});
}

class TransformationJourneySuccess extends TransformationJourneyState {
  final List<TransformationJourneyUpload> contentFromUser;
  TransformationJourneySuccess({this.contentFromUser});
}

class TransformationJourneyFailure extends TransformationJourneyState {
  final dynamic exception;

  TransformationJourneyFailure({this.exception});
}

class TransformationJourneyBloc extends Cubit<TransformationJourneyState> {
  TransformationJourneyBloc() : super(TransformationJourneyLoading());

  void getContentByUserId(String userId) async {
    try {
      List<TransformationJourneyUpload> contentUploaded = await TransformationJourneyRepository().getUploadedContentByUserId(userId);
      emit(TransformationJourneySuccess(contentFromUser: contentUploaded));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(TransformationJourneyFailure(exception: e));
      rethrow;
    }
  }

  Future<void> createTransformationJourneyUpload(FileTypeEnum type, XFile file, String userId, int indexForContent) async {
    try {
      TransformationJourneyUpload transformationJourneyUpload =
          await TransformationJourneyRepository.createTransformationJourneyUpload(type, file, userId, indexForContent);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(TransformationJourneyFailure(exception: e));
      rethrow;
    }
  }

  void emitTransformationJourneyFailure() {
    try {
      emit(TransformationJourneyFailure(exception: new Exception("Upload Aborted")));
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(TransformationJourneyFailure(exception: e));
      rethrow;
    }
  }

  void emitTransformationJourneyDefault({bool noValues = false}) {
    try {
      noValues ? emit(TransformationJourneyDefaultValue(contentFromUser: [])) : emit(TransformationJourneyDefault());
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(TransformationJourneyFailure(exception: e));
      rethrow;
    }
  }

  Future<void> changeContentOrder(TransformationJourneyUpload elementMoved, TransformationJourneyUpload elementReplaced, String userId) async {
    final bool isUpdated =
        await TransformationJourneyRepository.reorderElementsIndex(elementMoved: elementMoved, elementReplaced: elementReplaced, userId: userId);
    if (isUpdated) {
      List<TransformationJourneyUpload> contentUploaded = await TransformationJourneyRepository().getUploadedContentByUserId(userId);
      emit(TransformationJourneySuccess(contentFromUser: contentUploaded));
    } else {
      return;
    }
  }

  void markContentAsDeleted(String userId, TransformationJourneyUpload elementRemoved) async {
    try {
      bool isElementDeleted = await TransformationJourneyRepository().markElementAsDeleted(userId: userId, transformationJourneyItem: elementRemoved);
      emit(TransformationJourneyDeleteSuccess(elementDeleted: isElementDeleted));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(TransformationJourneyFailure(exception: e));
      rethrow;
    }
  }
}
