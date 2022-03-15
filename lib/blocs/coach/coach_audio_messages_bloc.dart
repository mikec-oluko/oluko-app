import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:oluko_app/models/submodels/audio_message_submodel.dart';
import 'package:oluko_app/repositories/coach_audio_messages_repository.dart';
import 'package:oluko_app/utils/video_process.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class CoachAudioMessagesState {}

class Loading extends CoachAudioMessagesState {}

class CoachAudioMessagesSuccess extends CoachAudioMessagesState {
  CoachAudioMessagesSuccess({this.coachAudioMessages});
  final List<CoachAudioMessage> coachAudioMessages;
}

class CoachAudioMessagesDispose extends CoachAudioMessagesState {
  CoachAudioMessagesDispose({this.coachAudioMessageDisposeValue});
  final List<CoachAudioMessage> coachAudioMessageDisposeValue;
}

class CoachAudioMessagesUpdate extends CoachAudioMessagesState {
  CoachAudioMessagesUpdate({this.coachAudioMessages});
  final List<CoachAudioMessage> coachAudioMessages;
}

class CoachAudioMessagesFailure extends CoachAudioMessagesState {
  CoachAudioMessagesFailure({this.exception});
  final dynamic exception;
}

class CoachAudioMessageBloc extends Cubit<CoachAudioMessagesState> {
  final CoachAudioMessagesRepository _coachAudioMessagesRepository = CoachAudioMessagesRepository();
  CoachAudioMessageBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;

  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
      emitCoachMessagesDispose();
    }
  }

  Future<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> getStream(String userId, String coachId) async {
    try {
      return subscription ??= _coachAudioMessagesRepository.getMessagesForCoachStream(userId, coachId).listen((snapshot) {
        final List<CoachAudioMessage> coachAudioMessages = [];

        if (snapshot.docs.isNotEmpty) {
          for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
            final Map<String, dynamic> messages = doc.data() as Map<String, dynamic>;
            coachAudioMessages.add(CoachAudioMessage.fromJson(messages));
           if(coachAudioMessages.isNotEmpty){
            coachAudioMessages.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
            }
          }
        }
        emit(CoachAudioMessagesSuccess(coachAudioMessages: coachAudioMessages.toList()));
      });
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAudioMessagesFailure(exception: exception));
      rethrow;
    }
  }

  void emitCoachMessagesDispose() async {
    try {
      emit(CoachAudioMessagesDispose(coachAudioMessageDisposeValue: []));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAudioMessagesFailure(exception: exception));
      rethrow;
    }
  }

  void saveAudioForCoach(File audioRecorded, String userId, String coachId) async {
    try {
      AudioMessageSubmodel audioContent = await _processAudio(audioRecorded);
      CoachAudioMessage messageUploaded = await _coachAudioMessagesRepository.saveAudioForCoach(audioContent, userId, coachId);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAudioMessagesFailure(exception: exception));
      rethrow;
    }
  }

  void markCoachAudioAsDeleted(CoachAudioMessage audioMessage) async {
    try {
      CoachAudioMessage deletedMessage = await _coachAudioMessagesRepository.markAudioAsDeleted(audioMessage);
      print(deletedMessage);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAudioMessagesFailure(exception: exception));
      rethrow;
    }
  }

  Future<AudioMessageSubmodel> _processAudio(File audioRecorded) async {
    const _uuid = Uuid();
    final String _audioId = _uuid.v1();
    AudioMessageSubmodel _audioMessageSubmodel;

    try {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final outDirPath = '${extDir.path}/AudioMessages/$_audioId';
      final audiosDir = Directory(outDirPath);
      audiosDir.createSync(recursive: true);
      final _audioPath = audioRecorded.path;

      _audioMessageSubmodel = await uploadAudio(_audioId, _audioPath);

      return _audioMessageSubmodel;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAudioMessagesFailure(exception: exception));
      rethrow;
    }
  }

  Future<AudioMessageSubmodel> uploadAudio(String audioId, String audioPath) async {
    String _audioUrl;
    AudioMessageSubmodel _audioMessageSubmodel;
    try {
      if (audioPath != null) {
        _audioUrl = await VideoProcess.uploadFile(audioPath, audioId);
        _audioMessageSubmodel = AudioMessageSubmodel(url: _audioUrl, duration: 0);
      }
      return _audioMessageSubmodel;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAudioMessagesFailure(exception: exception));
      rethrow;
    }
  }
}
