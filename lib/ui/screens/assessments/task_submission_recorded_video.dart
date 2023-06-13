import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';

class TaskSubmissionRecordedVideo extends StatefulWidget {
  TaskSubmissionRecordedVideo({this.videoUrl, this.task, key}) : super(key: key as Key);

  final String videoUrl;
  final Task task;

  @override
  _TaskSubmissionRecordedVideoState createState() => _TaskSubmissionRecordedVideoState();
}

class _TaskSubmissionRecordedVideoState extends State<TaskSubmissionRecordedVideo> {
  final _formKey = GlobalKey<FormState>();
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
            backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            appBar: OlukoAppBar(
              showTitle: true,
              showBackButton: true,
              title: widget.task.name,
              actions: [SizedBox(width: 30)],
            ),
            body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: OlukoNeumorphismColors.appBackgroundColor,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 1.5), child: Stack(children: [showVideoPlayer()]))
                        ],
                      ),
                    )))));
  }

  Widget showVideoPlayer() {
    return OlukoCustomVideoPlayer(
        videoUrl: widget.videoUrl,
        useConstraints: true,
        roundedBorder: OlukoNeumorphism.isNeumorphismDesign,
        whenInitialized: (ChewieController chewieController) => setState(() {
              _controller = chewieController;
            }));
  }
}
