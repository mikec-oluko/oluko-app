import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class OlukoExceptionMessage {
  static String getExceptionMessage(
      {@required ExceptionTypeEnum exceptionType, @required BuildContext context, ExceptionTypeSourceEnum exceptionSource}) {
    return exceptionSource == null
        ? getTitleForException(exceptionType: exceptionType, context: context)
        : '${getTitleForException(exceptionType: exceptionType, context: context)} ${getAditionalInfoForException(exceptionSource: exceptionSource, context: context)}';
  }

  static String getTitleForException({@required ExceptionTypeEnum exceptionType, @required BuildContext context}) {
    String defaultExceptionTitle = OlukoLocalizations.get(context, 'appFailed');
    switch (exceptionType) {
      case ExceptionTypeEnum.uploadFailed:
        defaultExceptionTitle = OlukoLocalizations.get(context, 'uploadFailed');
        break;
      case ExceptionTypeEnum.permissionsFailed:
        defaultExceptionTitle = OlukoLocalizations.get(context, 'requiredPermitsBody');
        break;
      case ExceptionTypeEnum.loadFileFailed:
        defaultExceptionTitle = OlukoLocalizations.get(context, 'fileLoadFailed');
        break;
      default:
    }
    return defaultExceptionTitle;
  }

  static String getAditionalInfoForException({@required ExceptionTypeSourceEnum exceptionSource, @required BuildContext context}) {
    String defaultExceptionSourceText = OlukoLocalizations.get(context, 'appFailed');
    switch (exceptionSource) {
      case ExceptionTypeSourceEnum.invalidFormat:
        defaultExceptionSourceText = OlukoLocalizations.get(context, 'fileFormatException');
        break;
      case ExceptionTypeSourceEnum.invalidDuration:
        defaultExceptionSourceText = OlukoLocalizations.get(context, 'invalidFileDuration');
        break;
      case ExceptionTypeSourceEnum.invalidValue:
        defaultExceptionSourceText = OlukoLocalizations.get(context, 'invalidValue');
        break;
      case ExceptionTypeSourceEnum.noFileSelected:
        defaultExceptionSourceText = OlukoLocalizations.get(context, 'noFileSelected');
        break;
      default:
    }
    return defaultExceptionSourceText;
  }
}
