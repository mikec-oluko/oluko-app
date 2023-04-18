import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class Chat extends StatelessWidget {
  final String title;

  const Chat({@required this.title});

  @override
  Widget build(BuildContext context) {
    return ChatScreen(title: title);
  }
}

class ChatScreen extends StatefulWidget {
  final String title;
  const ChatScreen({@required this.title});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _messages.add(text);
    });
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
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(title: Text(_messages[index]));
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 13.0),
            decoration: const BoxDecoration(
              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
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
                      onPressed: () => {
                            //   if (widget.title == OlukoLocalizations.get(context, 'filters'))
                            //     {filterBackButtonAction()}
                            //   else
                            //     {
                            //       if (widget.onPressed != null) {widget.onPressed()} else {Navigator.pop(context)}
                            //     }
                            // },
                          }),
                ),
                // IconButton(
                //   icon: Icon(Icons.send),
                //   onPressed: () => _handleSubmitted(_textController.text),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
