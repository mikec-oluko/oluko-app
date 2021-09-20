import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/chat.dart';
import 'package:oluko_app/repositories/chat_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class HiFiveSendState {}

class HiFiveSendLoading extends HiFiveSendState {}

class HiFiveSendSuccess extends HiFiveSendState {
  List<Chat> chat;
  HiFiveSendSuccess({this.chat});
}

class HiFiveSendFailure extends HiFiveSendState {
  final dynamic exception;

  HiFiveSendFailure({this.exception});
}

class HiFiveSendBloc extends Cubit<HiFiveSendState> {
  HiFiveSendBloc() : super(HiFiveSendLoading());

  void get(BuildContext context, String userId) async {
    try {
      //Get chat and message info from Chat repository
      List<Chat> chat = await ChatRepository().getByUserId(userId);
      emit(HiFiveSendSuccess(chat: chat));
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
