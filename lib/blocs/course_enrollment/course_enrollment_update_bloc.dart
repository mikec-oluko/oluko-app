import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/repositories/transformation_journey_repository.dart';
import 'package:oluko_app/repositories/users_selfies_repository.dart';
import 'package:path/path.dart' as p;
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseEnrollmentUpdateState {}

class Loading extends CourseEnrollmentUpdateState {}

class Failure extends CourseEnrollmentUpdateState {
  final dynamic exception;
  Failure({this.exception});
}

class SaveSelfieSuccess extends CourseEnrollmentUpdateState {
  CourseEnrollment courseEnrollment;
  SaveSelfieSuccess({this.courseEnrollment});
}

class CourseEnrollmentUpdateBloc extends Cubit<CourseEnrollmentUpdateState> {
  CourseEnrollmentUpdateBloc() : super(Loading());

  void saveMovementCounter(CourseEnrollment courseEnrollment, int segmentIndex, int sectionIndex, int classIndex, MovementSubmodel movement, int totalRounds,
      int currentRound, int counter) async {
    try {
      await CourseEnrollmentRepository.saveMovementCounter(
          courseEnrollment, segmentIndex, classIndex, sectionIndex, movement, totalRounds, currentRound, counter);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void saveSectionStopwatch(
      CourseEnrollment courseEnrollment, int segmentIndex, int sectionIndex, int classIndex, int totalRounds, int currentRound, int stopwatch) async {
    try {
      await CourseEnrollmentRepository.saveSectionStopwatch(courseEnrollment, segmentIndex, classIndex, sectionIndex, totalRounds, currentRound, stopwatch);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void saveSelfie(CourseEnrollment courseEnrollment, int classIndex, XFile file) async {
    emit(Loading());
    try {
      final thumbnail = await ImageUtils().getThumbnailForImage(file, 250);
      final thumbnailUrl = await _uploadFile(thumbnail, 'classes/' + courseEnrollment.classes[classIndex].id);
      final miniThumbnail = await ImageUtils().getThumbnailForImage(file, 50);
      final miniThumbnailUrl = await _uploadFile(miniThumbnail, 'classes/' + courseEnrollment.classes[classIndex].id + '/mini');
      final CourseEnrollment courseUpdated = await CourseEnrollmentRepository.updateSelfie(courseEnrollment, classIndex, thumbnailUrl, miniThumbnailUrl);
      UsersSelfiesRepository.update(thumbnailUrl);
      saveSelfieInCourse(courseEnrollment, classIndex);
      final List<TransformationJourneyUpload> uploadedContent = await TransformationJourneyRepository().getUploadedContentByUserId(courseEnrollment.userId);
      TransformationJourneyRepository.createTransformationJourneyUpload(FileTypeEnum.image, file, courseEnrollment.userId, uploadedContent.length);
      emit(SaveSelfieSuccess(courseEnrollment: courseUpdated));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }

  Future<void> saveSelfieInCourse(CourseEnrollment courseEnrollment, int classIndex) async {
    var thumbnailUrl = courseEnrollment.classes[classIndex].selfieThumbnailUrl;
    if (thumbnailUrl != null) {
      await CourseRepository.addSelfie(courseEnrollment.course.id, thumbnailUrl);
    }
  }

  static Future<String> _uploadFile(String filePath, String folderName) async {
    final file = File(filePath);

    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    final String downloadUrl = await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }
}
