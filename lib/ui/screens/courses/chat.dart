import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_chat_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/message_bubble.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class Chat extends StatelessWidget {
  final CourseEnrollment courseEnrollment;

  const Chat({
    @required this.courseEnrollment,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatScreen(courseEnrollment: courseEnrollment);
  }
}

class ChatScreen extends StatefulWidget {
  final CourseEnrollment courseEnrollment;

  const ChatScreen({
    @required this.courseEnrollment,
    Key key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  String message;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  CourseEnrollmentChatBloc _chatBloc;
  bool _isLoadingMoreMessages = false;
  double currentScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<CourseEnrollmentChatBloc>();
    _chatBloc.listenToMessages(widget.courseEnrollment.course.id);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _chatBloc.cancelMessagesSubscription();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
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

  Widget _buildMessagesList(List<Message> messages, String currentUserId) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification && _scrollController.offset <= _scrollController.position.minScrollExtent) {
          if (!_isLoadingMoreMessages) {
            _isLoadingMoreMessages = true;
            currentScrollPosition = _scrollController.position.maxScrollExtent;
            BlocProvider.of<CourseEnrollmentChatBloc>(context).getMessagesAfterMessage(messages[0], widget.courseEnrollment.course.id);
          }
          return true;
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          final message = messages[index];
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
          return Column(
            children: [
              _showTodayLabel(index, messages),
              MessageBubble(
                firstName: firstName,
                lastName: lastName ?? firstName,
                userImage: message.user.image,
                messageText: message.message,
                isCurrentUser: isCurrentUser,
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleNewMessagesScroll() {
    if (_scrollController.hasClients) {
      final previousMaxScrollExtent = _scrollController.position.maxScrollExtent;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newMaxScrollExtent = _scrollController.position.maxScrollExtent;
        final scrollDifference = newMaxScrollExtent - previousMaxScrollExtent;
        _scrollController.jumpTo(_scrollController.offset + scrollDifference);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            OlukoAppBar(showBackButton: true, title: widget.courseEnrollment.course.name, showTitle: true, courseImage: widget.courseEnrollment.course.image),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: Container(
                color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                child: BlocBuilder<CourseEnrollmentChatBloc, CourseEnrollmentChatState>(
                  builder: (context, state) {
                    if (state is MessagesUpdated) {
                      messages = state.messages;
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      return _buildMessagesList(messages, widget.courseEnrollment.userId);
                    } else if (state is MessagesScroll) {
                      _isLoadingMoreMessages = false;
                      final previousMessages = state.messages;
                      final newMessages = [...previousMessages, ...messages];
                      messages = newMessages;
                      _handleNewMessagesScroll();
                      return _buildMessagesList(messages, widget.courseEnrollment.userId);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
                decoration: const BoxDecoration(
                  color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: _handleSubmitted,
                      ),
                    ),
                    SizedBox(
                      height: 55,
                      width: 55,
                      child: _textController.value.text.isNotEmpty
                          ? OlukoNeumorphicCircleButton(
                              customIcon: const Icon(Icons.send, color: OlukoColors.grayColor),
                              onPressed: () => _handleSubmitted(_textController.text),
                            )
                          : OlukoNeumorphicCircleButton(
                              customIcon: const Icon(Icons.mic, color: OlukoColors.grayColor),
                              onPressed: () {
                                // record function here
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
