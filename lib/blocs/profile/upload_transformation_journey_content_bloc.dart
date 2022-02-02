import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/permissions.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/transformation_journey_repository.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class TransformationJourneyContentState {}

class TransformationJourneyContentLoading extends TransformationJourneyContentState {}

class TransformationJourneyContentDefault extends TransformationJourneyContentState {}

class TransformationJourneyContentOpen extends TransformationJourneyContentState {}

class TransformationJourneyContentSuccess extends TransformationJourneyContentState {}

class TransformationJourneyContentFailure extends TransformationJourneyContentState {
  dynamic exception;
  TransformationJourneyContentFailure({this.exception});
}

class TransformationJourneyRequirePermissions extends TransformationJourneyContentState {}

class TransformationJourneyContentBloc extends Cubit<TransformationJourneyContentState> {
  TransformationJourneyContentBloc() : super(TransformationJourneyContentDefault());

  void uploadTransformationJourneyContent({DeviceContentFrom uploadedFrom, int indexForContent}) async {
    XFile _image;
    try {

      if (!await PermissionsUtils.permissionsEnabled(uploadedFrom, checkMicrophone: false)) {
        emit(TransformationJourneyRequirePermissions());
        return;
      }
      
      final ImagePicker imagePicker = ImagePicker();
      if (uploadedFrom == DeviceContentFrom.gallery) {
        _image = await imagePicker.pickImage(source: ImageSource.gallery);
      } else if (uploadedFrom == DeviceContentFrom.camera) {
        _image = await imagePicker.pickImage(source: ImageSource.camera);
      }
      if (_image == null) {
        emit(TransformationJourneyContentFailure(exception: new Exception()));
        return;
      }
      emit(TransformationJourneyContentLoading());

      UserResponse user = await AuthRepository().retrieveLoginData();

      await TransformationJourneyRepository.createTransformationJourneyUpload(FileTypeEnum.image, _image, user.id, indexForContent);

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
}
