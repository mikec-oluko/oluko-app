import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/video_player.dart';

class TaskSubmissionRecordedVideo extends StatefulWidget {
  TaskSubmissionRecordedVideo({this.videoUrl, this.task, key}) : super(key: key);

  String videoUrl;
  Task task;

  @override
  _TaskSubmissionRecordedVideoState createState() =>
      _TaskSubmissionRecordedVideoState();
}

class _TaskSubmissionRecordedVideoState
    extends State<TaskSubmissionRecordedVideo> {
  final _formKey = GlobalKey<FormState>();
  SignUpResponse profileInfo;
  ChewieController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return form();
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(title: widget.task.name),
            body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 1.5),
                              child: Stack(children: showVideoPlayer()))
                        ],
                      ),
                    )))));
  }

  List<Widget> showVideoPlayer() {
    List<Widget> widgets = [];
    widgets.add(OlukoVideoPlayer(
        videoUrl: widget.videoUrl,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    return widgets;
  }
}