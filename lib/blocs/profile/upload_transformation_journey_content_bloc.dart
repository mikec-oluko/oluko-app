import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/transformation_journey_repository.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:oluko_app/models/utils/oluko_bloc_exception.dart';
import 'package:path/path.dart' as p;

abstract class TransformationJourneyContentState {}

class TransformationJourneyContentLoading extends TransformationJourneyContentState {}

class TransformationJourneyContentDefault extends TransformationJourneyContentState {}

class TransformationJourneyContentOpen extends TransformationJourneyContentState {}

class TransformationJourneyContentSuccess extends TransformationJourneyContentState {}

class TransformationJourneyContentDelete extends TransformationJourneyContentState {
  TransformationJourneyUpload elementToMarkAsDelete;
  TransformationJourneyContentDelete({this.elementToMarkAsDelete});
}

class TransformationJourneyContentFailure extends OlukoException with TransformationJourneyContentState {
  TransformationJourneyContentFailure({ExceptionTypeEnum exceptionType, ExceptionTypeSourceEnum exceptionSource, dynamic exception})
      : super(exceptionType: exceptionType, exception: exception, exceptionSource: exceptionSource);
}

class TransformationJourneyRequirePermissions extends TransformationJourneyContentState {
  String permissionRequired;
  TransformationJourneyRequirePermissions({this.permissionRequired});
}

class TransformationJourneyContentBloc extends Cubit<TransformationJourneyContentState> {
  TransformationJourneyContentBloc() : super(TransformationJourneyContentDefault());

  void uploadTransformationJourneyContent({DeviceContentFrom uploadedFrom, int indexForContent}) async {
    XFile _image;
    try {
      if (!await PermissionsUtils.permissionsEnabled(uploadedFrom, checkMicrophone: false)) {
        emit(TransformationJourneyRequirePermissions(permissionRequired: uploadedFrom.name));
        return;
      }
      final ImagePicker imagePicker = ImagePicker();
      if (uploadedFrom == DeviceContentFrom.gallery) {
        _image = await imagePicker.pickImage(
          source: ImageSource.gallery,
        );
      } else if (uploadedFrom == DeviceContentFrom.camera) {
        _image = await imagePicker.pickImage(
          source: ImageSource.camera,
        );
      }
      if (_image == null && _image is! XFile) {
        emit(TransformationJourneyContentFailure(
            exception: Exception(), exceptionType: ExceptionTypeEnum.loadFileFailed, exceptionSource: ExceptionTypeSourceEnum.noFileSelected));
        return;
      } else if (!(p.extension(_image.path) == ImageUtils.jpegFormat ||
          p.extension(_image.path) == ImageUtils.jpgFormat ||
          p.extension(_image.path) == ImageUtils.pngFormat)) {
        emit(TransformationJourneyContentFailure(
            exception: Exception(), exceptionType: ExceptionTypeEnum.uploadFailed, exceptionSource: ExceptionTypeSourceEnum.invalidFormat));
        return;
      }
      emit(TransformationJourneyContentLoading());

      final UserResponse _user = await AuthRepository().retrieveLoginData();

      await TransformationJourneyRepository.createTransformationJourneyUpload(FileTypeEnum.image, _image, _user.id, indexForContent);

      emit(TransformationJourneyContentSuccess());
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );

      emit(TransformationJourneyContentFailure(exception: e));
      rethrow;
    }
  }

  void emitDefaultState() {
    emit(TransformationJourneyContentDefault());
  }

  void openPanel() {
    emit(TransformationJourneyContentOpen());
  }

  void markContentAsDelete(TransformationJourneyUpload elementToDelete) {
    emit(TransformationJourneyContentDelete(elementToMarkAsDelete: elementToDelete));
  }
}
