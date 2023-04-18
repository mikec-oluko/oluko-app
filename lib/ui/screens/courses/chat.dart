import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_chat_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class Chat extends StatelessWidget {
  final String title;
  final String courseId;
  final String userId;

  const Chat({
    @required this.title,
    @required this.courseId,
    @required this.userId,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatScreen(title: title, courseId: courseId, userId: userId,);
  }
}

class ChatScreen extends StatefulWidget {
  final String title;
  final String courseId;
  final String userId;

  const ChatScreen({
    @required this.title,
    @required this.courseId,
    @required this.userId,
    Key key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String message;
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

    @override
  void initState() {
    super.initState();
    //BlocProvider.of<CourseEnrollmentChatBloc>(context).create();
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    print(ModalRoute.of(context).settings.name);
    BlocProvider.of<CourseEnrollmentChatBloc>(context).createMessage(widget.userId, widget.courseId, text);
    // setState(() {
    //   _messages.add(text);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        showBackButton: true,
        title: widget.title,
        showTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(title: Text(_messages[index]));
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
                      customIcon: const Icon(Icons.send, color: OlukoColors.grayColor), 
                      onPressed: () => _handleSubmitted(_textController.text)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
