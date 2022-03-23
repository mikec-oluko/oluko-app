import 'package:flutter/foundation.dart';
import 'package:oluko_app/helpers/enum_collection.dart';

class OlukoException {
  ExceptionTypeEnum exceptionType;
  ExceptionTypeSourceEnum exceptionSource;
  dynamic exception;
  OlukoException({@required this.exceptionType, this.exceptionSource, this.exception});
}
