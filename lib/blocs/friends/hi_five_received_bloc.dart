import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/chat.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/repositories/chat_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class HiFiveReceivedState {}

class HiFiveReceivedLoading extends HiFiveReceivedState {}

class HiFiveReceivedSuccess extends HiFiveReceivedState {
  bool hiFive;
  HiFiveReceivedSuccess({this.hiFive});
}

class HiFiveReceivedFailure extends HiFiveReceivedState {
  final dynamic exception;

  HiFiveReceivedFailure({this.exception});
}

class HiFiveReceivedBloc extends Cubit<HiFiveReceivedState> {
  HiFiveReceivedBloc() : super(HiFiveReceivedLoading());

  void get(BuildContext context, String userId, String targetUserId) async {
    try {
      List<Message> messages =
          await ChatRepository().getMessages(userId, targetUserId);

      bool hiFive = false;
      messages.forEach((Message message) =>
          message.message == Message().hifiveMessageCode
              ? hiFive = true
              : hiFive = false);
      emit(HiFiveReceivedSuccess(hiFive: hiFive));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(HiFiveReceivedFailure(exception: exception));
      rethrow;
    }
  }
}
