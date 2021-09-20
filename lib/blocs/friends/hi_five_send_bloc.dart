import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/chat.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/repositories/chat_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class HiFiveSendState {}

class HiFiveSendLoading extends HiFiveSendState {}

class HiFiveSendSuccess extends HiFiveSendState {
  Message message;
  HiFiveSendSuccess({this.message});
}

class HiFiveSendFailure extends HiFiveSendState {
  final dynamic exception;

  HiFiveSendFailure({this.exception});
}

class HiFiveSendBloc extends Cubit<HiFiveSendState> {
  HiFiveSendBloc() : super(HiFiveSendLoading());

  void set(BuildContext context, String userId, String targetUserId) async {
    try {
      //Get chat and message info from Chat repository
      final Message messageCreated =
          await ChatRepository().sendHiFive(userId, targetUserId);
      emit(HiFiveSendSuccess(message: messageCreated));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(HiFiveSendFailure(exception: exception));
      rethrow;
    }
  }
}
