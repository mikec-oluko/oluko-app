import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/chat.dart';
import 'package:oluko_app/repositories/chat_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class HiFiveReceivedState {}

class HiFiveReceivedLoading extends HiFiveReceivedState {}

class HiFiveReceivedSuccess extends HiFiveReceivedState {
  List<Chat> chat;
  HiFiveReceivedSuccess({this.chat});
}

class HiFiveReceivedFailure extends HiFiveReceivedState {
  final dynamic exception;

  HiFiveReceivedFailure({this.exception});
}

class HiFiveReceivedBloc extends Cubit<HiFiveReceivedState> {
  HiFiveReceivedBloc() : super(HiFiveReceivedLoading());

  void get(BuildContext context, String userId) async {
    try {
      //Get chat and message info from Chat repository
      List<Chat> chat = await ChatRepository().getByUserId(userId);
      emit(HiFiveReceivedSuccess(chat: chat));
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
