import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
      return subscription ??= _coachAudioMessagesRepository.getMessagesForCoachStream(userId, coachId).listen((snapshot) async {
        emit(Loading());
        List<CoachAudioMessage> audioMessages = [];
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.forEach((doc) {
            final Map<String, dynamic> content = doc.data();
            audioMessages.add(CoachAudioMessage.fromJson(content));
          });
          // TODO: disabled needs fix in firebase added event, pending writes, [created_at == null]
          // if (audioMessages.where((audioElement) => audioElement.createdAt == null).toList().isEmpty) {
          //   audioMessages.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
          // }
        }
        emit(CoachAudioMessagesSuccess(coachAudioMessages: audioMessages));
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

  void saveAudioForCoach({@required File audioRecorded, @required String userId, @required String coachId, Duration audioDuration}) async {
    try {
      final AudioMessageSubmodel audioContent = await _processAudio(audioRecorded, audioDuration);
      final CoachAudioMessage messageUploaded = await _coachAudioMessagesRepository.saveAudioForCoach(audioContent, userId, coachId);
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
      final CoachAudioMessage deletedMessage = await _coachAudioMessagesRepository.markAudioAsDeleted(audioMessage);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAudioMessagesFailure(exception: exception));
      rethrow;
    }
  }

  Future<AudioMessageSubmodel> _processAudio(File audioRecorded, Duration audioDuration) async {
    const _uuid = Uuid();
    final String _audioId = _uuid.v1();
    try {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final outDirPath = '${extDir.path}/AudioMessages/$_audioId';
      final audiosDir = Directory(outDirPath);
      audiosDir.createSync(recursive: true);
      final _audioPath = audioRecorded.path;

      AudioMessageSubmodel _audioMessageSubmodel = await uploadAudio(_audioId, _audioPath, audioDuration);
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

  Future<AudioMessageSubmodel> uploadAudio(String audioId, String audioPath, Duration audioDuration) async {
    String _audioUrl;
    AudioMessageSubmodel _audioMessageSubmodel;
    try {
      if (audioPath != null) {
        _audioUrl = await VideoProcess.uploadFile(audioPath, audioId);
        _audioMessageSubmodel = AudioMessageSubmodel(url: _audioUrl, duration: audioDuration.inMilliseconds);
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
