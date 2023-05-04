import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/chat_slider_bloc.dart';
import 'package:oluko_app/blocs/challenge/panel_audio_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_panel_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_chat_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/challenge_audio_section.dart';
import 'package:oluko_app/ui/components/chat_audio.dart';
import 'package:oluko_app/ui/components/message_bubble.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Chat extends StatelessWidget {
  final CourseEnrollment courseEnrollment;
  final UserResponse currentUser;
  final List<CourseEnrollment> enrollments;

  const Chat({
    @required this.courseEnrollment,
    this.currentUser,
    this.enrollments,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatScreen(courseEnrollment: courseEnrollment, enrollments: enrollments, currentUser: currentUser);
  }
}

class ChatScreen extends StatefulWidget {
  final CourseEnrollment courseEnrollment;
  final UserResponse currentUser;
  final List<CourseEnrollment> enrollments;
  const ChatScreen({
    @required this.courseEnrollment,
    this.currentUser,
    this.enrollments,
    Key key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  List<UserResponse> participants = [];
  String message;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  CourseEnrollmentChatBloc _chatBloc;
  bool _isLoadingMoreMessages = false;
  double currentScrollPosition = 0;

  PanelController panelController = PanelController();
  SoundRecorder recorder;

  final ValueNotifier<bool> _takenSurvey = ValueNotifier(false);

  void changeValueNotifier() {
    _takenSurvey.value = !_takenSurvey.value;
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CourseEnrollmentChatBloc>(context).dispose();
    BlocProvider.of<CourseEnrollmentChatBloc>(context).listenToMessages(widget.courseEnrollment.course.id);
    recorder = SoundRecorder();
    recorder.init();
    _textController.addListener(() {
      BlocProvider.of<CourseEnrollmentChatBloc>(context).changeButton(_textController.text.isEmpty);
    });
    BlocProvider.of<GenericAudioPanelBloc>(context).emitDefaultState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text != '' && text != null) {
      BlocProvider.of<CourseEnrollmentChatBloc>(context).createMessage(widget.courseEnrollment.userId, widget.courseEnrollment.course.id, text);
    }
  }

  Widget _showTodayLabel(int index, List<Message> messages) {
    if (index > 0) {
      final previousMessageDate = messages[index - 1].createdAt?.toDate() ?? Timestamp.now().toDate();
      final currentMessageDate = messages[index].createdAt?.toDate() ?? Timestamp.now().toDate();
      final now = DateTime.now();

      if (previousMessageDate.day != currentMessageDate.day &&
          currentMessageDate.day == now.day &&
          currentMessageDate.month == now.month &&
          currentMessageDate.year == now.year) {
        return const Center(
          child: Text(
            'Today',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      }
    }
    return const SizedBox();
  }

  Widget _buildMessagesList(List<Message> messages, String currentUserId, List<UserResponse> participants) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification && _scrollController.offset == _scrollController.position.maxScrollExtent) {
          if (!_isLoadingMoreMessages) {
            _isLoadingMoreMessages = true;
            currentScrollPosition = _scrollController.position.maxScrollExtent;
            BlocProvider.of<CourseEnrollmentChatBloc>(context).getMessagesAfterMessage(messages[messages.length - 1], widget.courseEnrollment.course.id);
          }
          return true;
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          final message = messages[index];
          final userIndex = participants.indexWhere((element) => messages[index].user.id == element.id);
          final isCurrentUser = message.user.id == currentUserId;
          String firstName;
          String lastName;
          if (message.user.name != null) {
            final List<String> splitName = message.user.name.split(' ');
            if (splitName.isNotEmpty) {
              firstName = splitName[0];
              if (splitName.length >= 2) {
                lastName = splitName[1];
              }
            }
          }
          return Wrap(
            children: [
              _showTodayLabel(index, messages),
              MessageBubble(
                firstName: firstName,
                lastName: lastName ?? firstName,
                userImage: message.user.image,
                messageText: message.message,
                isCurrentUser: isCurrentUser,
                user: userIndex == -1 ? null : participants[userIndex],
                authUserId: currentUserId,
                audioMessage: message?.audioMessage,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buttonSend(bool isText) {
    return BlocBuilder<CourseEnrollmentChatBloc, CourseEnrollmentChatState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double halfWidth = constraints.maxWidth;

            Widget buttonWidget = Container(
              width: halfWidth,
              child: OlukoNeumorphicCircleButton(
                customIcon: const Icon(Icons.send, color: OlukoColors.grayColor),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            );

            Widget chatAudioWidget = Container(
              width: halfWidth,
              child: GenericAudioRecorder(
                userId: widget.currentUser.id,
                onRecord: changeValueNotifier,
                onSave: onSaveAudio,
              ),
            );

            return (state is Changebutton && !state.showButton) ? buttonWidget : chatAudioWidget;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        appBar: OlukoAppBar(
            showBackButton: true,
            title: widget.courseEnrollment.course.name,
            showTitle: true,
            courseImage: widget.courseEnrollment.course.image,
            onPressed: () => {BlocProvider.of<ChatSliderBloc>(context).listenToMessages(widget.enrollments, widget.currentUser.id), Navigator.pop(context)}),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: Container(
                child: BlocBuilder<CourseEnrollmentChatBloc, CourseEnrollmentChatState>(
                  builder: (context, state) {
                    if (state is MessagesUpdated) {
                      final newMessages = state.messages;
                      newMessages.forEach((element) {
                       if(messages.where((message) => message.id == element.id).isEmpty){
                          messages = [element, ...messages];
                       }
                      });
                      return _buildMessagesList(messages, widget.courseEnrollment.userId, state.participants);
                    } else if (state is MessagesScroll) {
                      _isLoadingMoreMessages = false;
                      final previousMessages = state.messages;
                      final newMessages = [...messages, ...previousMessages];
                      final previousParticipants = state.participants;
                      final newParticipants = [...participants, ...previousParticipants];
                      participants = newParticipants;
                      messages = newMessages;
                      return _buildMessagesList(messages, widget.courseEnrollment.userId, participants);
                    } else if (messages.isNotEmpty) {
                      return _buildMessagesList(messages, widget.courseEnrollment.userId, participants);
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              )),
              SizedBox(
                height: 115,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  decoration: const BoxDecoration(
                    color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: _takenSurvey,
                          builder: (context, takenSurvey, child) {
                            if (_takenSurvey.value) {
                              return const SizedBox(
                                width: 0,
                              );
                            } else {
                              return Flexible(
                                flex: 6,
                                child: Center(
                                  child: SizedBox(
                                    child: SizedBox(
                                      width: 300,
                                      child: TextField(
                                        controller: _textController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 15.0),
                                        ),
                                        textAlignVertical: TextAlignVertical.center,
                                        onSubmitted: _handleSubmitted,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                      Flexible(
                        flex: 1,
                        child: _buttonSend(_textController.text.isNotEmpty),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void onSaveAudio(File audio, String userId, Duration audioDuration) {
    BlocProvider.of<CourseEnrollmentChatBloc>(context)
        .saveChatAudioMessage(audioRecorded: audio, userId: userId, courseId: widget.courseEnrollment.course.id, audioDuration: audioDuration);
  }
}
