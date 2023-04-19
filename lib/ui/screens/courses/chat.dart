import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_chat_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

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
  String message;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CourseEnrollmentChatBloc>().listenToMessages(widget.courseEnrollment.course.id);
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text != '' && text != null) {
      BlocProvider.of<CourseEnrollmentChatBloc>(context).createMessage(widget.courseEnrollment.userId, widget.courseEnrollment.course.id, text);
    }
  }

  Widget _buildMessagesList(List<Message> messages) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(title: Text(messages[index].message));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        showBackButton: true,
        title: widget.courseEnrollment.course.name,
        showTitle: true,
      ),
    body: Column(
      children: [
        Expanded(
          child: Container(
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            child: BlocBuilder<CourseEnrollmentChatBloc, CourseEnrollmentChatState>(
              builder: (context, state) {
                if (state is MessagesUpdated) {
                  final messages = state.messages;
                  return _buildMessagesList(messages);
                } else {
                  return Center(child: CircularProgressIndicator());
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
                    style: TextStyle(color: Colors.white),
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
                  child: OlukoNeumorphicCircleButton(
                      customIcon: const Icon(Icons.send, color: OlukoColors.grayColor), onPressed: () => _handleSubmitted(_textController.text)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
