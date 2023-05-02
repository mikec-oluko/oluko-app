import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/audio_message.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/audio_message_submodel.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/course_chat_repository.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/video_process.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class CourseEnrollmentChatState {}

class CourseEnrollmentLoading extends CourseEnrollmentChatState {}


class MessagesUpdated extends CourseEnrollmentChatState {
  final List<Message> messages;
  final List<UserResponse> participants;
  final DocumentSnapshot lastDocument;
  MessagesUpdated(this.messages, this.participants, {this.lastDocument});
}

class MessagesScroll extends CourseEnrollmentChatState {
  final List<Message> messages;
  final List<UserResponse> participants;
  MessagesScroll(this.messages, this.participants);
}

class Changebutton extends CourseEnrollmentChatState {
  final bool showButton;
  Changebutton(this.showButton);
}

class Failure extends CourseEnrollmentChatState {
  final dynamic exception;
  Failure({this.exception});
}

class CourseEnrollmentChatBloc extends Cubit<CourseEnrollmentChatState> {
  CourseEnrollmentChatBloc() : super(CourseEnrollmentLoading());

  StreamSubscription _messagesSubscription;

  @override
  void dispose() {
    if (_messagesSubscription != null) {
      _messagesSubscription.cancel();
      _messagesSubscription = null;
    }
  }

  Future<void> createMessage(String userId, String courseId, String userMessage) async {
    try {

      final DocumentReference<Object> userReference = UserRepository().getUserReference(userId);
      final UserResponse user = await UserRepository().getById(userId);
      final Course course = await CourseRepository.get(courseId);

      ObjectSubmodel userObj = ObjectSubmodel(id: userId, image: user.avatar, name: '${user.firstName} ${user.lastName}', reference: userReference);
      Message message = Message(message: userMessage, user: userObj);
      
      message.createdAt = Timestamp.now();
      await CourseChatRepository().createMessage(message, course.id);
    } catch (e) {
      emit(Failure());
    }
  }

  void listenToMessages(String courseChatId) {
    try{
      emit(CourseEnrollmentLoading());
      _messagesSubscription = CourseChatRepository().listenToMessagesByCourseChatId(courseChatId).listen((snapshot) async {
      final List<Message> messages = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
      if(messages.isNotEmpty){
        saveLastMessageUserSaw(courseChatId, messages[0]);
        final List<UserResponse> participants = await getUsers(messages);
        emit(MessagesUpdated(messages, participants));
      }
    });
    }catch(e){
      emit(Failure());
    }
  }

  Future<void> saveLastMessageUserSaw(String courseChatId, Message message) async {
    try {
      await CourseChatRepository().updateUsersLastSeenMessage(courseChatId, message);
    } catch (e) {
      emit(Failure());
    }
  }

  Future<void> getMessagesAfterMessage(Message message, String courseChatId) async {
    try {
      List<Message> messages = await CourseChatRepository().getMessagesAfterMessageId(courseChatId, message.id);
      final List<UserResponse> participants = await getUsers(messages);
      emit(MessagesScroll(messages, participants));
    }catch(exception, stackTrace){
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure());
    }
  }

  Future<List<UserResponse>> getUsers(List<Message> messages) async {
    final List<Future<DocumentSnapshot<Object>>> promises = messages.map((message) => message.user.reference.get()).toList();
    final List<DocumentSnapshot<Object>> userListDocuments = await Future.wait(promises);
    final Set<String> usersAdded = {};
    final List<UserResponse> participants = [];

    for (final doc in userListDocuments) {
      final UserResponse user = UserResponse.fromJson(doc.data() as Map<String, dynamic>);
      if (usersAdded.add(user.id)) {
        participants.add(user);
      }
    }
    return participants;
  }

  void changeButton(bool showButton){
    emit(Changebutton(showButton));
  }



    void saveChatAudioMessage({@required File audioRecorded, @required String userId, @required String courseId, Duration audioDuration}) async {
    try {
      final AudioMessageSubmodel audioContent = await _processAudio(audioRecorded, audioDuration);
      final DocumentReference<Object> userReference = UserRepository().getUserReference(userId);
      final UserResponse user = await UserRepository().getById(userId);

      ObjectSubmodel userObj = ObjectSubmodel(id: userId, image: user.avatar, name: '${user.firstName} ${user.lastName}', reference: userReference);
      AudioMessage message = AudioMessage(user: userObj, audioMessage: audioContent);

      message.createdAt = Timestamp.now();
      await CourseChatRepository().createMessage(message, courseId);

    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure());
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

      AudioMessageSubmodel _audioMessageSubmodel = await _uploadAudio(_audioId, _audioPath, audioDuration);
      return _audioMessageSubmodel;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  Future<AudioMessageSubmodel> _uploadAudio(String audioId, String audioPath, Duration audioDuration) async {
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
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
